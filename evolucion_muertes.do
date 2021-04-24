clear
global graphs "C:\Users\Rafael\Google Drive\MAESTRÍA ITAM\Investigación Aplicada\entrega final"


cd "C:\Users\Rafael\Google Drive\MAESTRÍA ITAM\Investigación Aplicada\temp"


set obs 142
gen n=_n
gen date=n+22024
drop n

sort date

merge 1:1 date using muertes_ocurridas.dta
drop _merge

sort date
merge 1:1 date using muertes_reportadas.dta


for varlist occ* rep*: replace X=0 if X==.
	
drop if date >22219
	
format date %dd-m
twoway (bar occ_deaths date, bcolor(red%30)) (bar rep_deaths date, bcolor(black%30)) if date>22024, ///
title(México) xtitle(Fecha)  legend(off) xsize(12) ysize(10)
graph save "$graphs\epicurve_tot.gph", replace

twoway (bar occ_deaths_metro date, bcolor(red%30)) (bar rep_deaths_metro date, bcolor(black%30)) if date>22024, ///
title(Hidalgo) xtitle(Fecha) legend(order(1 "Por fecha de ocurrencia" 2 "Por fecha de reporte")) xsize(12) ysize(10)
graph save "$graphs\epicurve_metro.gph", replace

graph combine  "$graphs\epicurve_tot.gph" "$graphs\epicurve_metro.gph", rows(2) xcommon imargin(tiny) xsize(13) ysize(17)

graph save "$graphs\epicurve_MexHgo.gph", replace
graph export "$graphs\epicurve_MexHgo.png", replace width(15000) height(16000)
graph export "$graphs\epicurve_MexHgo.pdf", replace 
