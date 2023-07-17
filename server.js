const express = require('express');
const { ethers } = require('ethers');

require('dotenv').config();

const { API_URL, PRIVATE_KEY, CONTRACT_ADDRESS } = process.env;

const provider = new ethers.providers.JsonRpcProvider(API_URL);
const signer = new ethers.Wallet(PRIVATE_KEY, provider);
const contractAddress = CONTRACT_ADDRESS;
const contractABI = require('./artifacts/contracts/MedBlock.sol/MedBlock.json').abi;

const contractInstance = new ethers.Contract(contractAddress, contractABI, signer);

const app = express();

// Middleware
app.use(express.json());

const port = 3000;

// Add Patient
app.post('/add-patient', async (req, res) => {
  try {
    const { name, age } = req.body;
    const tx = await contractInstance.addPatient(name, age);
    const receipt = await tx.wait();
    const patientAddress = receipt.events[0].args.id;
    res.send({ success: true, patientAddress });
  } catch (error) {
    res.status(500).send(error.message);
  }
});

// Add Doctor
app.post('/add-doctor', async (req, res) => {
  try {
    const { name } = req.body;
    const tx = await contractInstance.addDoctor(name);
    const receipt = await tx.wait();
    const doctorAddress = receipt.events[0].args.id;
    res.send({ success: true, doctorAddress });
  } catch (error) {
    res.status(500).send(error.message);
  }
});



// Give Access
app.post('/give-access', async (req, res) => {
  try {
    const { doctor_id, access_level } = req.body;
    const tx = await contractInstance.giveAccess(doctor_id, access_level);
    await tx.wait();
    res.send({ success: true });
  } catch (error) {
    res.status(500).send(error.message);
  }
});

// Change Access
app.post('/change-access', async (req, res) => {
  try {
    const { doctor_id, access_level } = req.body;
    const tx = await contractInstance.changeAccess(doctor_id, access_level);
    await tx.wait();
    res.send({ success: true });
  } catch (error) {
    res.status(500).send(error.message);
  }
});

// Remove Doctor
app.post('/remove-doctor', async (req, res) => {
  try {
    const { doctor_id } = req.body;
    const tx = await contractInstance.removeDoctor(doctor_id);
    await tx.wait();
    res.send({ success: true });
  } catch (error) {
    res.status(500).send(error.message);
  }
});

// Get Patient Data
app.post('/get-patient-data', async (req, res) => {
  try {
    const { patient_id } = req.body;
    const data = await contractInstance.getPatientData(patient_id);
    const { name, age } = data;
    res.send({ success: true, name, age });
  } catch (error) {
    res.status(500).send(error.message);
  }
});

// Get Doctor Data
app.post('/get-doctor-data', async (req, res) => {
  try {
    const { doctor_id } = req.body;
    const name = await contractInstance.getDoctorData(doctor_id);
    res.send({ success: true, name });
  } catch (error) {
    res.status(500).send(error.message);
  }
});

// Show Profile
app.get('/show-profile', async (req, res) => {
  try {
    const name = await contractInstance.showProfile();
    res.send({ success: true, name });
  } catch (error) {
    res.status(500).send(error.message);
  }
});

// Dashboard for patient
app.get('/dashboard/doctors-connected', async (req, res) => {
  try {
    const doctorsConnected = await contractInstance.doctorsConnected();
    res.send({ success: true, doctorsConnected });
  } catch (error) {
    res.status(500).send(error.message);
  }
});

// Dashboard for Doctors
app.get('/dashboard/patients-connected', async (req, res) => {
  try {
    const patientsConnected = await contractInstance.patientsConnected();
    res.send({ success: true, patientsConnected });
  } catch (error) {
    res.status(500).send(error.message);
  }
});




app.listen(port, ()=>{
  console.log("API server is listening on port 3000");
})
  
  // const ethers = require("ethers");
  // require('dotenv').config();
  // const API_URL = process.env.API_URL;
  // const PRIVATE_KEY = process.env.PRIVATE_KEY;
  // const contractAddress = process.env.CONTRACT_ADDRESS;
  
  // const provider = new ethers.providers.JsonRpcProvider(API_URL);
  // const signer = new ethers.Wallet(PRIVATE_KEY, provider);
  // const {abi} = require("./artifacts/contracts/MedBlock.sol/MedBlock.json");
  // const contractInstance = new ethers.Contract(contractAddress, abi, signer);