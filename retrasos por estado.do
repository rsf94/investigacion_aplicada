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

cd "$shape"
shp2dta using dest_2015gw, data(statesmex2) coor(coordmuns2) genid(id) replace

clear
use statesmex2.dta, clear
destring CVE_ENT, gen(entidad_res) force

merge 1:1 entidad_res using "C:\Users\Rafael\Google Drive\MAESTRÍA ITAM\Investigación Aplicada\shape files\mean_delays_bystate.dta"


spmap retraso_30 using coordmuns2, id(id) clmethod(custom) ///
clbreaks(0 3 5 10 15 30) /// 
legtitle("Días de retraso") legorder(lohi) legend(position(1)) legend(size(big))  ///
osize(vvthin vvthin vvthin vvthin vvthin vvthin vvthin vvthin) ocolor(none none none none none none none none)
graph save "$graphs\mexico_retrasos.gph"
graph export "$graphs\mexico_retrasos.pdf"


* para juntar con el de Hgo
graph use "$graphs\hidalgo_retrasos.gph"

graph combine  "$graphs\mexico_retrasos.gph" "$graphs\hidalgo_retrasos.gph", plotregion(color(white))

graph save "$graphs\retrasos_MexHgo.gph", replace
graph export "$graphs\retrasos_MexHgo.png", width(16000) height(10000) replace
