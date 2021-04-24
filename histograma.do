/*=========================================

ESTE DOFILE
ASIGNAMOS FECHA DE REPORTE A CADA DECESO

HACER HISTOGRAMAS

COLAPSAMOS LA INFORMACIÓN A NIVEL MUNICIPAL
Y POR FECHA PARA PODER HACER MAPAS Y GRÁFICAS
ADICIONALES

==============================================*/
clear 

*carpeta donde están los archivos en .csv
global raw "D:\Datos Covid"
*carpeta de bases temporales

*carpeta de bases procesadas
global data "C:\Users\Rafael\Google Drive\MAESTRÍA ITAM\Investigación Aplicada\bases juntas"

*carpeta de imágenes
*ESTA SÍ ESPECIFIQUEN SU CARPETA DENTRO DE LA CARPETA DE LA CLASE
global graphs "C:\Users\Rafael\Google Drive\MAESTRÍA ITAM\Investigación Aplicada\entrega final"

*carpeta de mapas
global shape "C:\Users\Rafael\Google Drive\MAESTRÍA ITAM\Investigación Aplicada\shape files"

*carpeta temporal de tu estado
global tempstate "C:\Users\Rafael\Google Drive\MAESTRÍA ITAM\Investigación Aplicada\temp"



import delimited "$raw\201130COVID19MEXICO.csv"
gen dead=fecha_def!="9999-99-99"
keep if clasificacion_final<=3
keep if dead==1
sort id_registro
merge 1:1 id_registro using "$data\reportdate_all.dta"
drop if _merge==2


gen deaddate=date(fecha_def, "YMD")
gen retraso=reportdate-deaddate
replace retraso=0 if retraso<0

gen retraso_30=retraso
replace retraso_30=30 if retraso>30
label variable retraso_30 "Retraso en reporte"

* collapse retraso, by(reportdate) <<- para ver evolución de retrasos con epidemia

set scheme s1color

twoway (hist retraso_30 if reportdate>22025, percent discrete bcolor(navy%30)) ///
(hist retraso_30 if reportdate>22025 & (entidad_res==13), percent discrete bcolor(orange%50)), ///
ytitle(Porcentaje)  xlabel(0(5)30) ylabel(0(5)30, angle(horizontal)) xtitle(Días de retraso) legend(order(1 "México" 2 "Hidalgo") region(lwidth(none)))
graph set window fontface "Times New Roman"

twoway (hist retraso_30 if reportdate>22025 & reportdate, percent discrete bcolor(navy%30)) ///
(hist retraso_30 if reportdate>22025 & (entidad_res==13), percent discrete bcolor(orange%50)), ///
xline(6,lcolor(orange)) text(25 6 "Media",color(orange)) text(25 10 "Media",color(navy)) xline(10,lcolor(navy)) ytitle(Porcentaje)  xlabel(0(5)30) ylabel(0(5)30, angle(horizontal)) xtitle(Días de retraso) legend(order(1 "México" 2 "Hidalgo") region(lwidth(none)))
graph set window fontface "Times New Roman"


graph export "$graphs\retrasos_MEXvsHID.png", width(16000) height(14000) replace
graph export "$graphs\retrasos_MEXvsHID.pdf",replace


/*este es el que pidió alejandro fajardo de la distribución para retrasos mayores a 30

twoway (hist retraso if reportdate>22025 & retraso>30, percent discrete bcolor(red%30)) ///
(hist retraso if reportdate>22025  & retraso>30 & (entidad_res==9|entidad_res==17|entidad_res==15), percent discrete bcolor(black%30)), ///
ytitle(Porcentaje)  legend(order(1 "México" 2 "CDMX y vecinos"))

*/

/*este es para hospitalizados y ambulatorios

twoway (hist retraso_30 if reportdate>22025 & tipo_paciente==1, percent discrete bcolor(red%30)) ///
(hist retraso_30 if reportdate>22025 & (entidad_res==9|entidad_res==17|entidad_res==15)  & tipo_paciente==2, percent discrete bcolor(black%30)), ///
ytitle(Porcentaje)  legend(order(1 "Ambulatorio" 2 "Hospitalizado"))

*/



/*========================================
CALCULAR RETRASOS PROMEDIO POR 
MUNICIPIO
==========================================*/
preserve

collapse (mean) retraso retraso_30, by(entidad_res municipio_res)
gen statemun=entidad_res*1000+municipio_res

keep statemun retraso retraso_30 entidad_res
sort statemun

save "$shape\mean_delays.dta", replace


restore


* para MAPA DE MEXICO
preserve

collapse (mean) retraso retraso_30, by(entidad_res)

keep retraso retraso_30 entidad_res
sort entidad_res

save "$shape\mean_delays_bystate.dta", replace


restore



/*=======================================
CALCULEN PARA CADA ESTADO
EL NÚMERO DE DECESOS POR FECHA
1. DE DEFUNCIÓN
2. DE REPORTE
EL CHISTE ES PODER COMPARAR LA
CURVA EPIDÉMICA DE SU ESTADO
CUANDO LA HACEMOS POR FECHA DE REPORTE
O POR FECHA DE DEFUNCIÓN
=========================================*/

*POR FECHA DE DEFUNCIÓN

preserve

*muertes
gen occ_deaths=1
*muertes en mi estado
gen occ_deaths_metro=(entidad_res==13)

collapse (sum) occ_deaths occ_deaths_metro, by(deaddate)

keep deaddate occ_deaths occ_deaths_metro

label variable occ_deaths "Decesos por fecha de ocurrencia (México)"
label variable occ_deaths_metro "Decesos por fecha de ocurrencia (CDMX y vecinos)"

rename deaddate date

sort date
cd "$tempstate"
save muertes_occuridas.dta, replace

restore


*POR FECHA DE REPORTE

preserve

*muertes
gen rep_deaths=1
*muertes en mi estado
gen rep_deaths_metro=(entidad_res==13)

collapse (sum) rep_deaths rep_deaths_metro, by(reportdate)

keep reportdate rep_deaths rep_deaths_metro

label variable rep_deaths "Decesos por fecha de reporte (México)"
label variable rep_deaths_metro "Decesos por fecha de reporte (CDMX y vecinos)"

rename reportdate date

sort date
cd "$tempstate"
save muertes_reportadas.dta, replace

restore




