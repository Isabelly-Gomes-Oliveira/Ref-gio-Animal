// requires:
require("dotenv").config();
const express = require("express");
const mssql = require('mssql');
const cors = require("cors");
const db = require("./db");

const app = express();

const porta = process.env.PORTA;
const stringSQL = process.env.CONNECTION_STRING;

// Evitar problemas com o CORS
app.use((request, response, next) =>
    { 
      response.header('Access-Control-Allow-Origin','*');
      next();
    });
    
app.use(cors());
app.use(express.json());

// função de conectar com o banco de dados
async function conectaBD() {
    try {
        await mssql.connect(stringSQL)
        console.log("Conectou ao Banco de Dados")
    } 
    catch (erro) {
        console.log(erro)
    }
}
// executa a função para conectar com o banco
conectaBD()

/******************************* ROTAS/ENDPOINTS *******************************/


/****************** COLOCANDO A API NO AR ******************/

app.listen(porta, (error) => {
    if (error)
    {
       console.log("ERRO no Servidor NODEJS rodando na porta 8081");
       return;
    } 
    console.log("Servidor NODEJS rodando na porta 8081!");
 });