clear

/* =============================================================================
GENERACIÓN DE MAPAS CON DISTRIBUCIÓN GEOGRÁFICO POR MUNICIPIO 
DE LOS CASOS Y DECESOS POR COVID
==============================================================================*/


set scheme s1color

*aquí llamamos a las rutas donde están los archivos
global main "D:\Datos Covid" 
global shape "C:\Users\Rafael\Google Drive\MAESTRÍA ITAM\Investigación Aplicada\shape files"
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


*sumamos casos y decesos dentro de cada municipio
collapse (sum) covid deceso, by(entidad_res municipio_res)
drop if municipio_res==999
gen statemun=entidad_res*1000+municipio_res

sort statemun

save "$shape\casos_decesos_mpio.dta", replace

/* =============================================================================
CREAMOS Y LLAMAMOS AL MAPA DE MUNICIPIOS
==============================================================================*/

*ESTOS SON LOS PROGRAMAS QUE TIENEN QUE INSTALAR EN STATA PARA PODER HACER MAPAS
*ssc install spmap
*ssc install shp2dta

cd "$shape"

shp2dta using national_municipal, data(munsmex) coor(coordmuns) genid(id) replace


/*================================================
LLAMAMOS AL MAPA EN FORMATO STATA
==================================================*/
clear
use munsmex.dta, clear
destring CVEGEO, gen(statemun) force

sort statemun
merge 1:1 statemun using casos_decesos_mpio.dta

drop if _merge==2

gen edo=floor(statemun/1000)
replace covid=0 if covid==.
spmap covid using coordmuns, id(id)
spmap covid using coordmuns,fcolor(Oranges) id(id) clmethod(custom) clbreaks(0 50 100 1000 2500 5000 7500 10000 20000) title("Hidalgo") ocolor(white white white white white white white white) osize(vvthin vvthin vvthin vvthin vvthin vvthin vvthin vvthin vvthin)


spmap covid using coordmuns if edo==13, fcolor(OrRd) id(id) clmethod(custom) clbreaks(0 50 75 100 200 400 600 800 1000   )  ///
legend(size(small)) legorder(lohi) legend(position(11)) ///
osize(vthin vthin vthin vthin vthin vthin vthin vthin vthin) title("Casos confirmados en Hidalgo") subtitle("al 27 de agosto de 2020")
graph save "$graphs\hidalgo_casos.gph",  replace 
graph export "$graphs\hidalgo_casos.png", width(15000) height(16000) replace

spmap deceso using coordmuns if edo==13,fcolor(OrRd) id(id) clmethod(custom) clbreaks(0 10 25 50 100 200 300 400)  ///
legend(size(vsmall)) legorder(lohi) legend(position(10)) ///
osize(vthin vthin vthin vthin vthin vthin vthin vthin vthin) title("Decesos confirmados en Hidalgo") subtitle("al 27 de agosto de 2020")
graph save "$graphs\hidalgo_cdmx.gph",  replace 
graph export "$graphs\hidalgo_decesos.png", width(15000) height(16000) replace


graph combine "$graphs\cdmx.gph" "$graphs\mexico.gph", plotregion(color(white))
graph export "$graphs\map1.tif", as(tif) replace

graph combine "$graphs\cdmx.gph" "$graphs\decesos_cdmx.gph", plotregion(color(white))
graph export "$graphs\map2.tif", as(tif) replace

spmap covid using coordmuns if edo==13, id(id) clmethod(custom) clbreaks(0 50 75 100 200 400 600 800 1000 3000  )  ///
legend(size(small)) legorder(lohi) legend(position(11)) legtitle("Casos confirmados") ///
osize(vthin vthin vthin vthin vthin vthin vthin vthin vthin)
graph save "$graphs\hidalgo_casos_st.gph",  replace 
graph export "$graphs\hidalgo_casos_st.png", width(15000) height(16000) replace

spmap deceso using coordmuns if edo==13,fcolor(OrRd) id(id) clmethod(custom) clbreaks(0 10 25 50 100 200 300 400)  ///
legend(size(small)) legorder(lohi) legend(position(10)) legtitle("Decesos") ///
osize(vthin vthin vthin vthin vthin vthin vthin vthin vthin)
graph save "$graphs\hidalgo_decesos_st.gph",  replace 
graph export "$graphs\hidalgo_decesos_st.png", width(15000) height(16000) replace

graph combine "$graphs\hidalgo_casos_st.gph" "$graphs\hidalgo_decesos_st.gph", plotregion(color(white))


gen morbilidad = (deceso/POB1)*100000
gen letalidad = deceso/covid

spmap morbilidad using coordmuns if edo==13, fcolor(OrRd) id(id) clmethod(custom) clbreaks(0 40 80 120 160 200  )  ///
legend(size(small)) legorder(lohi) legend(position(11)) legtitle("Muertes por cada 100,000 hab") ///
osize(vthin vthin vthin vthin vthin vthin vthin vthin )
graph save "$graphs\hidalgo_morbilidad.gph",  replace 
graph export "$graphs\hidalgo_morbilidad.pdf", replace

spmap letalidad using coordmuns if edo==13,fcolor(OrRd) id(id) clmethod(custom) clbreaks(0 0.10 0.20 0.30 0.40 0.60)  ///
legend(size(small)) legorder(lohi) legend(position(10)) legtitle("Tasa de letalidad") ///
osize(vthin vthin vthin vthin vthin vthin vthin vthin vthin)
graph save "$graphs\hidalgo_letalidad.gph",  replace 
graph export "$graphs\hidalgo_letalidad.pdf", replace

graph combine "$graphs\hidalgo_morbilidad.gph" "$graphs\hidalgo_letalidad.gph", plotregion(color(white))
