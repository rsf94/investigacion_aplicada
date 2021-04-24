clear

/* =============================================================================
DEFINIR RUTAS DE ARCHIVOS Y DONDE GUARDAR LOS RESULTADOS
 =============================================================================*/

*main indica folder del disco duro con bases de datos
global main "D:\Datos Covid" 
global graphs "C:\Users\Rafael\INSTITUTO TECNOLOGICO AUTONOMO DE MEXICO\EMILIO GUTIERREZ FERNANDEZ - Inv_Aplicada_2020_2\avances-estudiantes\Rafael Sandoval - Hidalgo\graphs"
global tables "C:\Users\Rafael\Google Drive\MAESTRÍA ITAM\Investigación Aplicada\entrega final"

*===============================================================================
* Cargar base de datos MÁS reciente
import delimited "$main\201130COVID19MEXICO.csv"



* identificar a pacientes con covid
gen covid = clasificacion_final<=3
label variable covid "Con prueba confirmatoria de COVID"

* identificar a fallecidos
gen deceso = fecha_def!="9999-99-99"
label variable deceso "Con fecha de defuncion registrada"

drop indigena

/* =============================================================================
CONSTUIR VARIABLES INDICADORAS DE CARACTERÍSTICAS OBSERVABLES
 =============================================================================*/

 * sexo
 gen mujer = sexo==1
 label variable mujer "Mujer"
 
 * lengua indígena
 gen indigena = habla_lengua_indig==1
 label variable indigena "Habla una lengua indígena"
 
 * grupos de edad
 gen menora10 = edad <=10
 gen edad11_20 = edad >10 & edad <=20
 gen edad21_30 = edad >20 & edad <=30
 gen edad31_40 = edad >30 & edad <=40
 gen edad41_50 = edad >40 & edad <=50
 gen edad51_60 = edad >50 & edad <=60
 gen edad61_70 = edad >60 & edad <=70
 gen edad71_80 = edad >70 & edad <=80
 gen edad81_plus = edad >80
 
label variable menora10 "Menor a 11"
label variable edad11_20 "Entre 11 y 20"
label variable edad21_30 "Entre 21 y 30"
label variable edad31_40 "Entre 31 y 40"
label variable edad41_50 "Entre 41 y 50"
label variable edad51_60 "Entre 51 y 60"
label variable edad61_70 "Entre 61 y 70"
label variable edad71_80 "Entre 71 y 80"
label variable edad81_plus "Mayor a 81"
   
 
* comorbilidades
 
 gen obeso = obesidad==1
 label variable obeso "Obesidad"
 
 gen diab = diabetes==1
 label variable diab "Diabetes"

 gen fuma = tabaquismo==1
 label variable fuma "Tabaquismo"

 gen enfisema = epoc==1
 label variable enfisema "EPOC"
 
 gen asmatico = asma==1
 label variable asmatico "Asma"
 
 gen hipert = hipertension==1
 label variable hipert "Hipertension"
 
 gen cardio = cardiovascular==1
 label variable cardio "Enfermedades cardiovasculares"
 
 gen renales = renal_cronica==1
 label variable renales "Enfermedad renal cronica"
 
 gen inm = inmusupr==1
 label variable inm "Inmunosupresion"
 
 gen tot_comorb = obeso + diab + fuma + enfisema + asmatico + enfisema + asmatico + hipert + cardio + renales + inm
 label variable tot_comorb "Numero de comorbilidades"
 
 gen morethanoneco = tot_comorb > 1
 label variable morethanoneco "Más de una comorbilidad"
 
 rename edad age
 
 global descriptives "menora10 edad* mujer indigena obeso diab fuma enfisema asmatico hipert cardio renales inm morethanoneco"
  

 gen hidalgo = entidad_res ==13

 balancetable hidalgo $descriptives using "$tables/hidalgo_vs_resto.tex" if covid== 1 & deceso==1,  varlabels replace ctitles("Resto del Pais" "Hidalgo" "Diferencia") 

 balancetable deceso $descriptives using "$tables/casos_vs_decesos_hidalgo2.tex" if covid== 1, varlabels replace ctitles("Casos confirmados" "Decesos confirmados" "Diferencia")

 
 