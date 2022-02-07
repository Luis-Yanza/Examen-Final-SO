#!/usr/bin/bash
for imag in *.png 
do
    convert "$imag" -crop 700x980+1500+90  "convert_$imag"

    tesseract "convert_$imag"  output -l spa  digits

    nced=${imag%png}"txt"
    egrep -o "[0-9]{9,10}" output.txt | sort | uniq > $nced
    rm -f "convert_$imag"

    while IFS= read -r line
      do
   awk  '{
            cedula = $line
            if(length(cedula)==10){
                dig_region=substr(cedula,0,2)
                if (int(dig_region) >=1 && int (dig_region) <=24){
                    ult_dig=int(substr(cedula,10,1))
                    pares=int(substr(cedula,2,1))+int(substr(cedula,4,1))+int(substr(cedula,6,1))+int(substr(cedula,8,1))
                    numero1=int(substr(cedula,1,1))
                    numero1=(numero1*2)
                    if(numero1 >9) { numero1=(numero1-9)}
                    numero3=int(substr(cedula,3,1))
                    numero3=(numero3*2)
                    if(numero3 >9 ) { numero3=(numero3-9) }
                    numero5=int(substr(cedula,5,1))
                    numero5=numero5*2
                    if(numero5 >9) {numero5=(numero5-9)}
                    numero7=int(substr(cedula,7,1))
                    numero7=numero7*2    
                    if(numero7 >9) {numero7=(numero7-9)}
                    numero9=int(substr(cedula,9,1))
                    numero9=numero9*2
                    if(numero9 >9) {numero9=(numero9-9)}
                    impares=numero1+numero3+numero5+numero7+numero9
                    total=(pares+impares)
                    totstr=total+""
                    prim_dig=substr(totstr,0,1)
                    decena=(int(prim_dig)+1)*10
                    validador=decena-total
                    if(validador==10) 
                    {dig_val=0}
                    if(validador==ult_dig){
                        print (cedula ": Numero de cedula es Valida")}
                    if (validador !=ult_dig){
                        print (cedula ": Numero de cedula Invalida")}
                }else { print (cedula ": Numero de cedula Invalida")
                    print "Numero de cedula no pertenece al Ecuador"
                }
            }else{ print (cedula ": Numero de cedula Invalida")
                 print "la cedula ingresada no tienes 10 digito"}
        }'

    done < $nced

    fecha=${nced:3:10}
    echo "$fecha" > listado_tmp.csv 
        while IFS= read -r line
        do

        c=$(echo $line | cut -f2 -d,) 
        asiste=$(grep -o $c $nced | wc -w) 
if [ $asiste = 0 ]; then
        echo "NO" >> listado_tmp.csv
else
        echo "SI" >> listado_tmp.csv
fi 
done <<< $(tail -n+2 lista-so.csv)
cp lista-so.csv copia.csv
paste -d, copia.csv listado_tmp.csv > lista-so.csv    

echo "fecha toma de asistencia :" $fecha 
done  
echo " Se acabo de tomar lista por completo"
rm -Rf output.txt
