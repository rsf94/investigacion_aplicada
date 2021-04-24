clear

import delimited "C:\Users\Rafael\Google Drive\MAESTRÍA ITAM\Investigación Aplicada\entrega final\por reporte y por ocurrencia al 30nov\deaths_hidalgo.csv", encoding(UTF-8) 

 gen fecha = date(date,"DMY")
 format fecha %d

 twoway (line reportadas fecha) (line ocurridas fecha), xlabel(,format(%tdMonYY)) ytitle(Número de decesos)   ylabel(, angle(horizontal)) xtitle("") legend(order(1 "Por fecha de reporte" 2 "Por fecha de ocurrencia") region(lwidth(none)))
graph set window fontface "Times New Roman"