clear

/* =============================================================================
GENERACIÓN DE MAPAS CON DISTRIBUCIÓN GEOGRÁFICO POR MUNICIPIO 
DE LOS CASOS Y DECESOS POR COVID
==============================================================================*/


set scheme s1color

*aquí llamamos a las rutas donde están los archivos
global main "D:\Datos Covid" 
global shape "C:\Users\Rafael\Google Drive\MAESTRÍA ITAM\Investigación Aplicada\shapes states"
global graphs "C:\Users\Rafael\Google Drive\MAESTRÍA ITAM\Investigación Aplicada\entrega final"

*===============================================================================

/* =============================================================================
Primero calculamos las medidas de lo que queremos mapear para cada municipio
==============================================================================*/


*esta es la base de datos correspondiente al 27 de agosto
import delimited "$main\201130COVID19MEXICO.csv"

*casos
gen covid = clasificacion_final<=3

*decesos
gen deceso=(fecha_def!="9999-99-99" & covid==1)


collapse (sum) covid deceso, by(entidad_res)

save "$shape\casos_decesos_estados.dta", replace

cd "$shape"
shp2dta using dest_2015gw, data(statesmex2) coor(coordmuns2) genid(id) replace

clear
use statesmex2.dta, clear
destring CVE_ENT, gen(entidad_res) force

merge 1:1 entidad_res using casos_decesos_estados.dta

spmap covid using coordmuns2, id(id)

spmap covid using coordmuns2,fcolor(Reds) id(id) clmethod(custom) clbreaks( 3000 10000 20000 30000 40000 60000 80000 100000) title("Hidalgo") 

spmap deceso using coordmuns2,fcolor(OrRd) id(id) clmethod(custom) ///
clbreaks( 0 1000 2000 3000 4000 6000 8000 10000) /// 
title("Decesos por Covid-19 en México") subtitle("al 27 de agosto de 2020") ///
legorder(lohi) legend(position(1)) legend(size(big)) ///
osize(vvthin vvthin vvthin vvthin vvthin vvthin vvthin vvthin) ocolor(white white white white white white white white)
graph save "$graphs\mexico_decesos.gph"
graph export "$graphs\mexico_decesos.png", width(16000) height(10000) replace


spmap covid using coordmuns2,fcolor(OrRd) id(id) clmethod(custom) ///
clbreaks( 0 10000 20000 30000 40000 60000 80000 100000) ///
title("Casos confirmados de Covid-19 en México") subtitle("al 27 de agosto de 2020") ///
legorder(lohi) legend(position(1)) legend(size(big)) ///
osize(vvthin vvthin vvthin vvthin vvthin vvthin vvthin vvthin) ocolor(white white white white white white white white)
graph save "$graphs\mexico_casos.gph"
graph export "$graphs\mexico_casos.png", width(16000) height(10000) replace

graph combine "$graphs\mexico_casos.gph" "$graphs\mexico_decesos.gph",title("México")



spmap deceso using coordmuns2,fcolor(OrRd) id(id) clmethod(custom) ///
clbreaks( 0 1000 2000 3000 4000 6000 8000 10000 12000 16000) /// 
legorder(lohi) legend(position(1)) legend(size(small)) legtitle("Decesos") ///
osize(vvthin vvthin vvthin vvthin vvthin vvthin vvthin vvthin vvthin) ocolor(white white white white white white white white white)
graph save "$graphs\mexico_decesos_st.gph", replace
graph export "$graphs\mexico_decesos_st.pdf", replace


spmap covid using coordmuns2, id(id) clmethod(custom) ///
clbreaks( 0 10000 20000 30000 40000 60000 80000 100000) ///
legorder(lohi) legend(position(1)) legend(size(small)) legtitle("Casos confirmados") ///
osize(vvthin vvthin vvthin vvthin vvthin vvthin vvthin vvthin) ocolor(white white white white white white white white)
graph save "$graphs\mexico_casos_st.gph", replace
graph export "$graphs\mexico_casos_st.png", width(16000) height(10000) replace

graph combine "$graphs\mexico_casos_st.gph" "$graphs\mexico_decesos_st.gph",title("México")
