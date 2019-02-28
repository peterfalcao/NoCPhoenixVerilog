`ifndef __DEFINES
`define __DEFINES
//---------------------------------------------------------
//-- CONSTANTES INDEPENDENTES
//---------------------------------------------------------
`define NPORT 5
`define NROT 4
`define EAST 0
`define WEST 1
`define SOUTH 2
`define NORTH 3
`define LOCAL 4
//--------------------------------------------------------
//-- CONSTANT DEPENDENTE DA LARGURA DE BANDA DA REDE
//---------------------------------------------------------
`define TAM_FLIT 16
`define METADEFLIT (`TAM_FLIT/2)
`define QUARTOFLIT (`TAM_FLIT/4)
//---------------------------------------------------------
//-- VARIAVEIS DO NOVO HARDWARE
//---------------------------------------------------------
`define ROUTERCONTROL 2
//tipos de routercontrol
`define invalidRegion 0
`define validRegion 1
`define faultPort 2
`define portError 3
//fim tipos de routercontrol
//SWITCHCONTROL
//STATE
`define STATE 3
`define S0 0
`define S1 1
`define S2 2
`define S3 3
`define S4 4
`define S5 5
//------------------------------
//SUBTIPOS TIPOS E FUNCOES
//-----------------------------
`define reg3 3
`define reg8 8
`define reg32 32
`define NP_REGF (`TAM_FLIT*`NPORT)
`define NP_REG3 (`reg3*`NPORT)
// regNrot ([`NROT-1])
// regNport [`NPORT-1:0]
// regflit ([`TAM_FLIT-1:0]);
// regmetadeflit [`METADE_FLIT-1:0]
// regquartoflit [`QUARTOFLIT-1:0] 
// pointer [`TAM_POINTER-1:0];
// [`TAM_BUFFER-1:0]buff  [`TAM_FLIT-1:0];
// [`NPORT-1:0] arrayNport_reg3 [`reg3 -1:0]
// [`NPORT-1:0] arrayNport_reg8[`reg8 -1:0]
// [`NPORT-1:0] arrayNport_regflit [`TAM_FLIT-1:0];
//  [`NROT-1:0] arrayNrot_reg3 [`reg3 -1:0]
// [`NROT-1: 0] arrayNrot_regflit [`TAM_FLIT-1:0];
// [`NROT-1:0] arrayNrot_regmetadeflit [`METADE_FLIT-1:0];
// [`NROT-1:0] arrayNrot_regNport [`NPORT-1:0];


`endif