!/usr/bin/bash
# Eliminar los exapcio en blanco y cambiar por _
for f in *.png;  do mv "$f" `echo $f | tr ' ' '_'`;done
# Recorre todos los archivos de tipo png del  directorio actual 

for archivo in *.png 
do
    echo "Convirtiendo $archivo"
    #  Recortar la imagen
    convert "$archivo" -crop 700x980+1500+90  "convert_$archivo"

    echo "Buscando cedulas"
    #Tesseract para poder obtener las cedulas de las imagenes
    tesseract "convert_$archivo"  output -l spa  digits

    asistencia=${archivo%png}"txt"
    egrep -o "[0-9]{9,10}" output.txt | sort | uniq > $asistencia  # aplicamos el filt>
    # para solo obtener las cedulas necesarias  filtradas
    rm -f "convert_$archivo"

    #echo "Archivo $asistencia" # imprimimos el archivo con las cedulas filtradas de c>

    #validar si la cedula es valida
    while IFS= read -r line   # recorremos linea a linea el archivo $asistencia
    do
      awk '{            
            cedula = $line # tomamos el valor de la cedula
            if(length(cedula)==10){
                dig_region=substr(cedula,0,2)
                if (int(dig_region) >=1 && int (dig_region) <=24){
                    ult_dig=int(substr(cedula,10,1))
                    #agrupar los numeros pares
                    pares=int(substr(cedula,2,1))+int(substr(cedula,4,1))+int(substr(c>
                    #print(pares)           
                    #agrupamos los impares y le multiplicamos por un factor de 2 si la>
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
                    #suma total
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
                 print "la cedula ingresada no tienes 10 digito"}}'

    done < $asistencia
fecha=${asistencia:3:10} # Obtenemos la fecha del archivo
    echo "$fecha" > listado_tmp.csv

    while IFS= read -r line   # Recorre cada linea de listado_tmp.CSV
    do
        #echo "$line"
        c=$(echo $line | cut -f2 -d,)  # aqui obtenemos la cedula del archivo CSV

        asiste=$(grep -o $c $asistencia | wc -w) 
        # Validar si el estudiante asisitio
        if [ $asiste = 0 ]; then
            echo "NO" >> listado_tmp.csv # Escribe la asistencia del estudiante
        else
            echo "SI" >> listado_tmp.csv
        fi

    done <<< $(tail -n+2 lista-so.csv)  # Del archivo original toma desde  la segunda >
    # y enviamos el archivo para recorrerlo linea a linea

    cp lista-so.csv copia.csv # Hacemos una copia del archivo Csv original para agrega>
    paste -d, copia.csv listado_tmp.csv > lista-so.csv    
    # Redirecciona al archivo original
    echo "fecha toma de asistencia :" $fecha

done  # fin del bucle for de todo el script
rm -Rf output.txt
