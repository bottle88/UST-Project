// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

contract MedBlock {
    enum AccessLevel {
        None,
        ReadOnly,
        ReadWrite
    }

    mapping(address => mapping(address => AccessLevel)) public patientToDoctor;
    mapping(address => patient) public patientMap;
    mapping(address => doctor) public doctorMap;

    mapping(bytes32 => fileInfo) fileMap;
    mapping(address => fileInfo[]) private patientFiles;

    struct fileInfo {
        string file_name;
        string file_type;
        string file_hash;
    }

    struct patient {
        string name;
        uint256 age;
        string gender;
        string contact_info;
        address id;
        address[] doctorsConnectedToaPatientList;
        bytes32[] files;
    }

    struct doctor {
        string name;
        uint256 age;
        string gender;
        string contact_info;
        string hospital_connected;
        address id;
        address[] patientsConnectedToaDoctorList;
    }

    function addPatient(string memory _name, uint256 _age) external {
        require(patientMap[msg.sender].id == address(0), "Patient already exists");

        patient memory p;
        p.name = _name;
        p.age = _age;
        p.id = msg.sender;
        patientMap[msg.sender] = p;
    }

    function addDoctor(string memory _name) external {
        require(doctorMap[msg.sender].id == address(0), "Doctor already exists");

        doctor memory d;
        d.name = _name;
        d.id = msg.sender;
        doctorMap[msg.sender] = d;
    }

    modifier validPatient(address id) {
        require(patientMap[id].id != address(0), "Invalid patient");
        _;
    }

    modifier validDoctor(address id) {
        require(doctorMap[id].id != address(0), "Invalid doctor");
        _;
    }

    // Pass as {"doctor_id", 1 } - For ReadOnly in Remix IDE
    // Pass as {"doctor_id", 2 } - For ReadWrite in Remix IDE

    function giveAccess(address doctor_id, AccessLevel accessLevel) validPatient(msg.sender) validDoctor(doctor_id) external {
        require(accessLevel == AccessLevel.ReadOnly || accessLevel == AccessLevel.ReadWrite, "Invalid access level");

        patientToDoctor[msg.sender][doctor_id] = accessLevel;

        patientMap[msg.sender].doctorsConnectedToaPatientList.push(doctor_id);
        doctorMap[doctor_id].patientsConnectedToaDoctorList.push(msg.sender);
    }

    // Pass as {"doctor_id", 1 } - For ReadOnly in Remix IDE
    // Pass as {"doctor_id", 2 } - For ReadWrite in Remix IDE

    function changeAccess(address doctor_id, AccessLevel accessLevel) external {
        require(patientToDoctor[msg.sender][doctor_id] == AccessLevel.ReadOnly || patientToDoctor[msg.sender][doctor_id] == AccessLevel.ReadWrite, "Cannot change access");
        patientToDoctor[msg.sender][doctor_id] = accessLevel;
    }

    function returnIndex(address addr) internal view returns (int) {
        for (uint256 i = 0; i < patientMap[msg.sender].doctorsConnectedToaPatientList.length; i++) {
            if (patientMap[msg.sender].doctorsConnectedToaPatientList[i] == addr) {
                return int256(i);
            }
        }
        return -1; // Return -1 when doctor is not found
    }

    function removeDoctor(address doctor_id) external {
        require(patientToDoctor[msg.sender][doctor_id] == AccessLevel.ReadOnly || patientToDoctor[msg.sender][doctor_id] == AccessLevel.ReadWrite, "Doctor is not connected to the patient");

        delete patientToDoctor[msg.sender][doctor_id];

        int256 index = returnIndex(doctor_id);
        require(index >= 0, "Doctor not found in the patient's list");

        uint256 uintIndex = uint256(index);

        // Move the last element to the position of the removed doctor
        patientMap[msg.sender].doctorsConnectedToaPatientList[uintIndex] = patientMap[msg.sender].doctorsConnectedToaPatientList[patientMap[msg.sender].doctorsConnectedToaPatientList.length - 1];
        patientMap[msg.sender].doctorsConnectedToaPatientList.pop();
    }

    function getPatientData(address patient_id) external view validPatient(patient_id)  returns (string memory name, uint256 age) {
        require(patientToDoctor[patient_id][msg.sender] == AccessLevel.ReadOnly || patientToDoctor[patient_id][msg.sender] == AccessLevel.ReadWrite, "Doctor does not have access");

        patient memory p = patientMap[patient_id];
        return (p.name, p.age);
    }

    function getDoctorData(address doctor_id) external view validDoctor(doctor_id) returns (string memory name) {
        require(doctorMap[doctor_id].patientsConnectedToaDoctorList.length > 0, "No connected patients");

        doctor memory d = doctorMap[doctor_id];
        return d.name;
    }

    function showProfile() external view returns (string memory name) {
        patient memory p = patientMap[msg.sender];
        doctor memory d = doctorMap[msg.sender];

        if (p.id != address(0)) {
            return p.name;
        } else if (d.id != address(0)) {
            return d.name;
        } else {
            return "Something went wrong";
        }
    }

    // Dashboard for patient
    function doctorsConnected() validPatient(msg.sender) external view returns (address[] memory) {
        return patientMap[msg.sender].doctorsConnectedToaPatientList;
    }

    // Dashboard for Doctors
    function patientsConnected() validDoctor(msg.sender) external view returns (address[] memory) {
        return doctorMap[msg.sender].patientsConnectedToaDoctorList;
    }

    modifier validWriteAccess(address patient_id) {
        require(patient_id == msg.sender || patientToDoctor[patient_id][msg.sender] == AccessLevel.ReadWrite, "Doctor does not have write access to patient");
        _;
    }

    function updatePatientDetails(address patient_id, string memory newName, uint256 newAge, string memory newGender, string memory newContactInfo) external validWriteAccess(patient_id) {
        patient storage p = patientMap[patient_id];

        if (bytes(newName).length > 0 && keccak256(bytes(newName)) != keccak256(bytes(p.name))) {
            p.name = newName;
        }

        if (newAge > 0 && newAge != p.age) {
            p.age = newAge;
        }

        if (bytes(newGender).length > 0 && keccak256(bytes(newGender)) != keccak256(bytes(p.gender))) {
            p.gender = newGender;
        }

        if (bytes(newContactInfo).length > 0 && keccak256(bytes(newContactInfo)) != keccak256(bytes(p.contact_info))) {
            p.contact_info = newContactInfo;
        }
    }

    function addFile(string memory _file_name, string memory _file_type, string memory _file_hash) external validPatient(msg.sender) {
        patientFiles[msg.sender].push(fileInfo({file_name: _file_name, file_type: _file_type, file_hash: _file_hash}));
    }


}

// Below code's logic , yet to be fuinalised , after the APIs for above functions are done!!

    // function updatePatientDetails(
    //     string memory newName,
    //     uint256 newAge,
    //     string memory newGender,
    //     string memory newContactInfo
    // ) external validPatient(msg.sender) {
    //     // updatePatientDetails(msg.sender, newName, newAge, newGender, newContactInfo);
    // }


    // function addFile(string memory _file_name, string memory _file_type, string memory _file_hash) external validPatient(msg.sender) {
    // //     patient storage p = patientMap[msg.sender];
    // //     p.files.push(_fileHash); 
    // //     fileMap[_fileHash] = fileInfo({file_name:_file_name, file_type:_file_type, file_hash:_fileHash});

    //          patientFiles[msg.sender].push(fileInfo({file_name:_file_name, file_type:_file_type, file_hash:_file_hash})) ;
    // }

    // modifier checkAccessFiles(address id){
        
    //     _;
    // }

    // function giveAccessFiles(address doctor_id) external {
        
    // }

    // function revokeAccessFiles(address doctor_id) external {

    // }

    // function viewPatientFiles(address patient_id) checkAccessFiles(msg.sender) public view returns(fileInfo[] memory){
    //     return patientFiles[patient_id];
    // }
