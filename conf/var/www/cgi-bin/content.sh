#!/bin/ash

[ -f "functions.sh" ] && . functions.sh

mem_t="Libre | Cache | Usada"
cpu_t="Libre | Sistema | Usuario"
dis_t="Libre | Temporal | Usado"

dashboard_components="memoria cpu disco"
configuracion_components="Nombre Codigo Ubicacion Resolucion Red Proxy Impresion"
servicios_components="Slim LPD Adlagent Red SSHD Xinetd"
xinetd_components="HTTPD VNC"

servicios() {
# todavia no se que hacer aqui
    echo '<div class="col-sm-9 col-sm-offset-3 col-md-10 col-md-offset-2 main">'
    echo '<h1 class="page-header">Servicios activos del terminal LeTSAS</h1>'
    echo '<div class="row placeholders">'
    echo '<div class="placeholder">'
    echo '<div class="table-responsive">'
    echo '<table class="table config">'
    echo '<tbody>'
    case "$1" in
        "vg" )
            for s in $servicios_components
            do
                servicio_i "$s"
                #echo '<br/>'
            done
        ;;
        * )
            #echo "<tr><td clas='left'><h4>${1}</h4></td>"
            servicio_i "$1" "detail"
        ;;
    esac
    echo '</tbody></table>'
    echo '</div> <!-- table-responsive -->'
    echo '</div> <!-- placeholder -->'
    echo '</div> <!-- placeholders -->'
    echo '</div> <!-- main -->'

}

servicio_i(){
    case "$1" in
         "Slim" )
            process_running slim
            get_parm action
            if [ $? -eq 0 ]; then
                if [ "$action" == "restartslim" ]; then
                    getpid "slim" && restartservice "slim" $slimpid
                fi
            fi
            echo "<tr><td class='left headcolor' colspan='2'><h4>Sesi&oacute;n gr&aacute;fica del terminal</h4></td></tr>"
            echo "<tr class='config'><td class='left' width='20%'><a href=\"?servicios=1&${1}=1\"><h5>Servicio de inicio de sesi&oacute;n</h5></td>"
            echo "<td class='left'><form name='slim' action='?servicios=1&slim=1' method='get'>"
            echo "<input type='hidden' name='servicios' value='1'>"
            echo "<input type='hidden' name='Slim' value='1'>"
            echo "<input type='hidden' name='action' value='restartslim'>"
            echo "<h5><b>Estado: $slim </b></h5>"
            echo "<h5><input type='submit' value='Reiniciar servicio'></h5>"
            echo "</form></td></tr>"
        ;;
        "Adlagent" )
           process_running adlagent
           get_parm action
           if [ $? -eq 0 ]; then
               if [ "$action" == "restartadlagent" ]; then
                   getpid "adlagent" && restartservice "adlagent" $adlagentpid
               fi
           fi
           echo "<tr><td class='left headcolor' colspan='2'><h4>Agente Altiris del terminal</h4></td></tr>"
           echo "<tr class='config'><td class='left' width='20%'><a href=\"?servicios=1&${1}=1\"><h5>Servicio de agente Altiris</h5></td>"
           echo "<td class='left'><form name='adlagent' action='?servicios=1&adlagent=1' method='get'>"
           echo "<input type='hidden' name='servicios' value='1'>"
           echo "<input type='hidden' name='Adlagent' value='1'>"
           echo "<input type='hidden' name='action' value='restartadlagent'>"
           echo "<h5><b>Estado: $adlagent </b></h5>"
           echo "<h5><input type='submit' value='Reiniciar servicio'></h5>"
           echo "</form></td></tr>"
       ;;
       "LPD" )
           process_running lpd
           get_parm action
           if [ $? -eq 0 ]; then
               if [ "$action" == "restartlpd" ]; then
                   getpid "lpd" && restartservice "lpd" $lpdpid
               fi

           fi
           echo "<tr><td class='left headcolor' colspan='2'><h4>Agente de impresi&oacute;n del terminal</h4></td></tr>"
           echo "<tr class='config'><td class='left' width='20%'><a href=\"?servicios=1&${1}=1\"><h5>Servicio de impresi&oacute;n</h5></td>"
           echo "<td class='left'><form name='lpd' action='?servicios=1&lpd=1' method='get'>"
           echo "<input type='hidden' name='servicios' value='1'>"
           echo "<input type='hidden' name='LPD' value='1'>"
           echo "<input type='hidden' name='action' value='restartlpd'>"
           echo "<h5><b>Estado: $lpd </b></h5>"
           echo "<h5><input type='submit' value='Reiniciar servicio'></h5>"
           echo "</form></td></tr>"
       ;;
       "SSHD" )
           process_running dropbear
           get_parm action
           if [ $? -eq 0 ]; then
               if [ "$action" == "restartdropbear" ]; then
                   getpid "dropbear" && restartservice "dropbear" $dropbearpid
               fi
           fi
           echo "<tr><td class='left headcolor' colspan='2'><h4>Servidor SSH del terminal</h4></td></tr>"
           echo "<tr class='config'><td class='left' width='20%'><a href=\"?servicios=1&${1}=1\"><h5>Servicio de SSHD</h5></td>"
           echo "<td class='left'><form name='SSHD' action='?servicios=1&SSH=1' method='get'>"
           echo "<input type='hidden' name='servicios' value='1'>"
           echo "<input type='hidden' name='SSHD' value='1'>"
           echo "<input type='hidden' name='action' value='restartdropbear'>"
           echo "<h5><b>Estado: $dropbear </b></h5>"
           echo "<h5><input type='submit' value='Reiniciar servicio'></h5>"
           echo "</form></td></tr>"
       ;;
       "Red" )
           get_net_mode
           get_net_ip
           get_parm action
           if [ $? -eq 0 ]; then
               if [ "$action" == "restartnetworking" ]; then
                   restartservice "networking"
               fi
           fi
           if [ "$ip" != "" ]; then
               net="Red en modo $netmode con IP $ip"
           else
               net="Red en modo $netmode parada"
           fi
           echo "<tr><td class='left headcolor' colspan='2'><h4>Servio de red del terminal</h4></td></tr>"
           echo "<tr class='config'><td class='left' width='20%'><a href=\"?servicios=1&${1}=1\"><h5>Servicio de red</h5></td>"
           echo "<td class='left'><form name='SSHD' action='?servicios=1&red=1' method='get'>"
           echo "<input type='hidden' name='servicios' value='1'>"
           echo "<input type='hidden' name='Red' value='1'>"
           echo "<input type='hidden' name='action' value='restartnetworking'>"
           echo "<h5><b>Estado: $net </b></h5>"
           echo "<h5><input type='submit' value='Reiniciar servicio'></h5>"
           echo "</form></td></tr>"
       ;;
       "Xinetd" )
           process_running xinetd
           get_parm action
           if [ $? -eq 0 ]; then
               if [ "$action" == "restartxinetd" ]; then
                   getpid "xinetd" && restartservice "xinetd" $xinetdpid
               fi
           fi
           echo "<tr><td class='left headcolor' colspan='2'><h4>Demonio Extendido de Internet (xinetd)</h4></td></tr>"
           echo "<tr class='config'><td class='left' width='20%'><a href=\"?servicios=1&${1}=1\"><h5>Servicio de xinetd</h5></td>"
           echo "<td class='left'><form name='xinetd' action='?servicios=1&xinetd=1' method='get'>"
           echo "<input type='hidden' name='servicios' value='1'>"
           echo "<input type='hidden' name='Xinetd' value='1'>"
           echo "<input type='hidden' name='action' value='restartaxinetd'>"
           echo "<h5><b>Estado: $xinetd </b></h5>"
           echo "<h5><input type='submit' value='Reiniciar servicio'></h5>"
           echo "</form></td></tr>"
           for serv in $xinetd_components
           do
               xinetd_process_active $serv
               echo "<tr class='config'><td></td><td class='left'><h5><b>Servicio de ${serv}</b></h5>"
               eval status=\$${serv}status
               echo "<h5>$status</b></h5></td></tr>"
           done
       ;;
    esac
}

informacion() {
    echo '<div class="col-sm-9 col-sm-offset-3 col-md-10 col-md-offset-2 main">'
    echo '<h1 class="page-header">Informaci&oacute;n del terminal LeTSAS</h1>'
    echo '<h2 class="sub-header" id="identidad">Identidad</h2>'
    echo '<div class="table-responsive">'
    echo '<table class="table table-striped">'
    echo '<tbody>'
    echo '<tr>'
    echo '<td width='20%'>Nombre</td>'
    get_hostname
    echo "<td>${hostname}</td>"
    echo '</tr>'
    echo '<tr>'
    echo '<td width='20%'>C&oacute;digo CGES</td>'
    get_code
    echo "<td>${code}</td>"
    echo '</tr>'
    echo '</tbody>'
    echo '</table>'
    echo '</div>'
    echo '<h2 class="sub-header" id="bios">BIOS</h2>'
    echo '<div class="table-responsive">'
    echo '<table class="table table-striped">'
    echo '<tbody>'
    echo '<tr>'
    echo '<td width='20%'>Versi&oacute;n</td>'
    dmidecode_string bios-version
    echo "<td>${bios_version}</td>"
    echo '</tr>'
    echo '<tr>'
    echo '<td>Fecha</td>'
    dmidecode_string bios-release-date
    echo "<td>${bios_release_date}</td>"
    echo '</tr>'
    echo '</tbody>'
    echo '</table>'
    echo '</div>'
    echo '<h2 class="sub-header" id="sistema">Sistema</h2>'
    echo '<div class="table-responsive">'
    echo '<table class="table table-striped">'
    echo '<tbody>'
    echo '<tr>'
    echo '<td width='20%'>Fabricante</td>'
    dmidecode_string system-manufacturer
    echo "<td>${system_manufacturer}</td>"
    echo '</tr>'
    echo '<tr>'
    echo '<td>Modelo</td>'
    dmidecode_string system-product-name
    echo "<td>${system_product_name}</td>"
    echo '</tr>'
    echo '<tr>'
    echo '<td>N&uacute;mero de serie</td>'
    dmidecode_string chassis-serial-number
    [ "`echo ${chassis_serial_number} | awk '{print $1}'`" == "" ] && dmidecode_string baseboard-serial-number && chassis_serial_number=${baseboard_serial_number}
    echo "<td>${chassis_serial_number}</td>"
    echo '</tr>'
    echo '<tr>'
    echo '<td>Versi&oacute;n</td>'
    dmidecode_string baseboard-product-name
    echo "<td>${baseboard_product_name}</td>"
    echo '</tr>'
    echo '</tbody>'
    echo '</table>'
    echo '</div>'
    echo '<h2 class="sub-header" id="pym">Procesador y memoria</h2>'
    echo '<div class="table-responsive">'
    echo '<table class="table table-striped">'
    echo '<tbody>'
    echo '<tr>'
    echo '<td width='20%'>CPU</td>'
    get_cpu_info
    echo "<td>${cpuinfo}</td>"
    echo '</tr>'
    echo '<tr>'
    echo '<td>Memoria RAM (MB)</td>'
    get_ram_info
    echo "<td>$raminfo</td>"
    echo '</tr>'
    echo '<tr>'
    echo '<td>Memoria swap ZRAM (MB)</td>'
    get_swap_info
    echo "<td>$swapinfo</td>"
    echo '</tr>'
    echo '<tr>'
    echo '<td>Disco Flash</td>'
    get_hdd_info
    echo "<td>$hddinfo</td>"
    echo '</tr>'
    echo '</tbody>'
    echo '</table>'
    echo '</div>'
    echo '<h2 class="sub-header" id="informacion">Informaci&oacute;n de red</h2>'
    echo '<div class="table-responsive">'
    echo '<table class="table table-striped">'
    echo '<tbody>'
    echo '<tr>'
    echo '<td width='20%'>Dispositivo</td>'
    get_net_info
    echo "<td>${netinfo}</td>"
    echo '</tr>'
    echo '<tr>'
    echo '<td>MAC</td>'
    get_net_mac
    echo "<td>$mac</td>"
    echo '</tr>'
    echo '<tr>'
    echo '<td>Interfaz</td>'
    echo '<td>ETH0</td>'
    echo '</tr>'
    echo '</tbody>'
    echo '</table>'
    echo '</div>'
    echo '<h2 class="sub-header" id="soporte">Soporte</h2>'
    echo '<div class="table-responsive">'
    echo '<table class="table table-striped">'
    echo '<tbody>'
    echo '<tr>'
    echo '<td width='20%'>Fabricante</td>'
    echo '<td></td>'
    echo '</tr>'
    echo '<tr>'
    echo '<td>Versi&oacute;n</td>'
    echo '<td></td>'
    echo '</tr>'
    echo '<tr>'
    echo '<td>Fecha</td>'
    echo '<td></td>'
    echo '</tr>'
    echo '</tbody>'
    echo '</table>'
    echo '</div>'
    echo '</div>'
}

dashboard_i() {
    get_memory_stat
    get_cpu_stat
    get_hdd_stat
    echo '<br/>'
    echo -n '<span class="text-muted">'
    eval echo -n \$"${1::3}""_t"
    echo '</span>'
    echo '<div class="progress">'
    echo -n '<div class="progress-bar progress-bar-success" style="width: '
    eval echo -n \$"${1::3}""_f"
    echo '%">'
    eval echo -n \$"${1::3}""_f"
    echo '%'
    echo '</div>'
    echo -n '<div class="progress-bar progress-bar-warning" style="width: '
    eval echo -n \$"${1::3}""_c"
    echo '%">'
    eval echo -n \$"${1::3}""_c"
    echo '%'
    echo '</div>'
    echo -n '<div class="progress-bar progress-bar-danger" style="width: '
    eval echo -n \$"${1::3}""_u"
    echo '%">'
    eval echo -n \$"${1::3}""_u"
    echo '%'
    echo '</div>'
    echo '</div> <!-- progress -->'
    if [ "$2" == "detail" ]
    then
            echo '<div class="input-group">'
            echo '<span class="input-group-addon"></span>'
            echo '<textarea class="form-control inactive" rows="18" style="font-family:monospace;">'
            eval echo \"\$"${1::3}""_r"\"
            echo '</textarea>'
            echo '</div><!-- Input Group -->'
    fi
 }

dashboard() {
    echo '<div class="col-sm-9 col-sm-offset-3 col-md-10 col-md-offset-2 main">'
    echo '<h1 class="page-header">Estado del terminal LeTSAS</h1>'
    echo '<div class="row placeholders">'
    echo '<div class=placeholder">'
    echo '<div class="table-responsive">'
    case "$1" in 
        "vg" )
            for f in $dashboard_components
            do
                echo "<a href=\"?dashboard=1&${f}=1\">"
                echo "<h4 class=\"pull-left\">${f}</h4>"
                echo '</a>'
                dashboard_i $f
                echo '<br/>' 
            done
            ;;
        * )
            echo "<h4 class=\"pull-left\">${1}</h4>"
            dashboard_i $1 "detail"
            ;;
        esac
   echo '</div> <!-- table-responsive -->'
   echo '</div> <!-- placeholder -->'
   echo '</div> <!-- placeholders -->'
   echo '</div> <!-- main -->'
}

configuracion() {
    echo '<div class="col-sm-9 col-sm-offset-3 col-md-10 col-md-offset-2 main">'
    echo '<h1 class="page-header">Configuraci&oacute;n del terminal LeTSAS</h1>'
    echo '<div class="row placeholders">'
    echo '<div class="placeholder">'
    echo '<div class="table-responsive">'
    echo '<table class="table config">'
    echo '<tbody>'
    case "$1" in
        "vg" )
            for f in $configuracion_components
            do
                configuracion_i "$f"
                #echo '<br/>'
            done
            ;;
        * )
            #echo "<tr><td clas='left'><h4>${1}</h4></td>"
            configuracion_i "$1" "detail"
            ;;
        esac
   echo '</tbody></table>'
   echo '</div> <!-- table-responsive -->'
   echo '</div> <!-- placeholder -->'
   echo '</div> <!-- placeholders -->'
   echo '</div> <!-- main -->'
}

configuracion_i() {
    case "$1" in
        "Nombre" )
            get_hostname
            get_parm action
            if [ $? -eq 0 ]; then
                if [ "$action" == "setname" ]; then
                    get_parm nhostname && set_hostname $nhostname
                    hostname=$nhostname
                fi
            fi
            echo "<tr><td class='left headcolor' colspan='2'><h4>Identificaci&oacute;n del terminal</h4></td></tr>"
            echo "<tr class='config'><td class='left' width='20%'><a href=\"?configuracion=1&${1}=1\"><h5>Nombre del terminal</h5></td>"
            echo "<td class='left'><form name='nombre' action='?configuracion=1&nombre=1' method='get'>"
            echo "<input type='hidden' name='configuracion' value='1'>"
            echo "<input type='hidden' name='Nombre' value='1'>"
            echo "<input type='hidden' name='action' value='setname'>"
            echo "<h5><input type='text' name='nhostname' value=\"$hostname\">"
            echo "<br><input type='submit' value='Cambiar'></h5>"
            echo "</form></td></tr>" 
            #echo "<br><h4>${hostname}</h4>"
        ;;
        "Codigo" )
            get_code
            get_parm action && [ "$action" == "setcode" ] && get_parm ncode && set_code $ncode && code=$ncode
            echo "<tr class='config'><td class='left' width='20%'><a href=\"?configuracion=1&${1}=1\"><h5>C&oacute;digo del terminal</h5></td>"
            echo "<td class='left'><form name='codigo' action='?configuracion=1&codigo=1' method='get'>"
            echo "<input type='hidden' name='configuracion' value='1'>"
            echo "<input type='hidden' name='Codigo' value='1'>"
            echo "<input type='hidden' name='action' value='setcode'>"
            echo "<h5><input type='text' name='ncode' value=\"$code\">"
            echo "<br><input type='submit' value='Cambiar'></h5>"
            echo "</form></td></tr>"
        ;;
	"Ubicacion" )
	    get_location
	    get_contactphone
	    get_parm action && [ "$action" == "setlocation" ] && get_parm nlocation && get_parm ncontactphone && set_location $nlocation && set_contactphone $ncontactphone && get_urldecoded $nlocation location && contactphone=$ncontactphone
            echo "<tr class='config'><td class='left' width='20%'><a href=\"?configuracion=1&${1}=1\"><h5>Ubicaci&oacute;n del terminal</h5></td>"       
            echo "<td class='left'><form name='codigo' action='?configuracion=1&ubicacion=1' method='get'>"                                              
            echo "<input type='hidden' name='configuracion' value='1'>"                                                                               
            echo "<input type='hidden' name='Ubicacion' value='1'>"                                                                                      
            echo "<input type='hidden' name='action' value='setlocation'>"                                                                                
            echo "<h5>Lugar f&iacute;sico (Indicar planta, consulta, etc.)<br><input type='text' name='nlocation' value=\"$location\"></h5>"
	    echo "<h5>Tel&eacute;fono de contacto<br><input type='text' name='ncontactphone' value=\"$contactphone\">"                                                                               
            echo "<br><input type='submit' value='Cambiar'></h5>"                                                                                     
            echo "</form></td></tr>"                                                                                                                  

	;;
        "Resolucion" )
            get_parm action && [ "$action" == "setres" ] && get_parm nresolucion && set_res $nresolucion && resolucion=$nresolucion
            echo "<tr><td class='left headcolor' colspan='2'><h4>Aspecto del terminal</h4></td></tr>"                                                 
            echo "<tr class='config'><td class='left' width='20%'><a href=\"?configuracion=1&${1}=1\">"                                               
            echo "    <h5>Resoluci&oacute;n de la pantalla</h5></td>"                                                                                 
            echo "<td class='left'><form name='resolucion' action='?configuracion=1&resolucion=1' method='get'>"                                      
            echo "<input type='hidden' name='configuracion' value='1'>"                                                                               
            echo "<input type='hidden' name='Resolucion' value='1'>"                                                                                  
            echo "<input type='hidden' name='action' value='setres'>"                                                                                 
                                                                                                                                                      
            #echo "<h5>Resolucion<br>"
	    echo "<select name='nresolucion'>"                                                                                      
            #get_resolution
            selected=""                                                                                                                               
            [ "$resolucion" == "800x600" ] && selected=" selected"                                                                                    
            echo "  <option value='800x600'${selected}>800x600</option>"                                                                              
            selected=""                                                                                                                               
            [ "$resolucion" == "1024x768" ] && selected=" selected"                                                                                   
            echo "  <option value='1024x768'${selected}>1024x768</option>"                                                                            
            selected=""                                                                                                                               
            [ "$resolucion" == "1280x1024" ] && selected=" selected"                                                                                  
            echo "  <option value='1280x1024'${selected}>1280x1024</option>"                                                                          
            echo "</select>"                                                                                                                     
            #users=`ls -1 /home/`                                                                                                                      
            #echo "<h5>Usuario<br><select name='nuser'>"                                                                                               
            #echo selected=""
            #echo "  <option value=\"todos\"${selected}>Todos</option>"
	    #for user in $users; do
	    #	 selected=""
	    #	 [ "$user" == "$nuser" ] && selected=" selected"                                                                                                                    
            #    echo "  <option value=\"$user\"${selected}>$user</option>"                                                                                      
            #done                                                                                                                                      
            #echo "</select>"                                                                                                                          
            echo "<br><input type='submit' value='Cambiar'></h5>"                                                                                     
            echo "</form></td></tr>"                                                                                                                  
            #echo "<br><h4>${resolucion}</h4>"
        ;;
        "Red" )
            get_net_mode
            get_net_ip
            get_net_mask
            get_net_mac
            get_net_gw
            get_net_dns
            get_net_domain
	    get_net_forcelink
	    get_net_changemac
            get_parm action
	    validateerror=0
            if [ "$action" == "setnet" ]; then
                get_parm nmode
                get_parm nip
		valid_ip $nip
		if [ $? -ne 0 ]; then
		    echo "<h5 class='text-danger bg-danger text-left'>DIRECCION IP INCORRECTA</h5>"
		    validateerror=1
		fi 
                get_parm nnetmask
		valid_ip $nnetmask
		if [ $? -ne 0 ]; then                                                                                                                 
                    echo "<h5 class='text-danger bg-danger text-left'>MASCARA DE RED INCORRECTA</h5>"                                                                                           
		    validateerror=1
                fi
                get_parm ngateway
		valid_ip $ngateway                                                                                                                    
                if [ $? -ne 0 ]; then                                                                                                                 
                    echo "<h5 class='text-danger bg-danger text-left'>PUERTA DE ENLACE INCORRECTA</h5>"
		    validateerror=1
                fi
                get_parm ndns
		get_urldecoded $ndns alldns
		for dnsip in $alldns; do
		    valid_ip $dnsip                                                                                                                    
                    if [ $? -ne 0 ]; then                                                                                                                 
                        echo "<h5 class='text-danger bg-danger text-left'>DNS $dnsip INCORRECTO</h5>"                                                                                         
			validateerror=1
                    fi
		done
                get_parm ndomain
		get_parm nforcelink
		get_parm nchangemac
		[ "$nforcelink" != "true" ] && nforcelink="false"
		[ "$nchangemac" != "true" ] && nchangemac="false"
		if [ $validateerror -eq 0 ]; then
                    if [ "$nmode" == "dhcp"  ]; then
                    	set_net "$nmode" "$nforcelink" "$nchangemac"
                    else
                    	set_net "$nmode" "$nforcelink" "$nchangemac" "$nip" "$nnetmask" "$ngateway" "$ndns" "$ndomain"
                    fi
		fi
            fi
            echo "<tr><td class='left headcolor' colspan='2'><h4>Conectividad del terminal</h4></td></tr>"
            echo "<tr class='config'><td class='left' width='20%'><a href=\"?configuracion=1&${1}=1\">"
            echo "<h5>Configuraci&oacute;n de red del terminal</h5></td>"
            echo "<td class='left'><form name='red' action='?configuracion=1&Red=1' method='get'>"
            echo "<input type='hidden' name='configuracion' value='1'>"
            echo "<input type='hidden' name='Red' value='1'>"
            echo "<input type='hidden' name='action' value='setnet'>"
            echo "<h5>Modo de configuraci&oacute;n de red:<br><select name='nmode'>"
            selected=""
            [ "$netmode" == "dhcp" ] && selected=" selected"
            echo "  <option value='dhcp'${selected}>DHCP</option>"
            selected=""
            [ "$netmode" == "manual" ] && selected=" selected"
            echo "  <option value='manual'${selected}>Manual</option>"
            echo "</select></h5>"
            disabled=""
            if [ "$netmode" == "dhcp" ]; then
                disabled="disabled"
            fi
            echo "<h5>IP del terminal:<br><input type='text' name='nip' value=\"$ip\" $disabled></h5>"
            echo "<h5>M&aacute;scara del terminal:<br><input type='text' name='nnetmask' value=\"$netmask\" $disabled></h5>"
            echo "<h5>Puerta de enlace del terminal:<br><input type='text' name='ngateway' value=\"$gateway\" $disabled></h5>"
            echo "<h5>Dominio de b&uacute;squeda del terminal:<br><input type='text' name='ndomain' value=\"$domain\" $disabled></h5>"
            echo "<h5>Servidores de nombres del terminal:<br><input type='text' name='ndns' value=\"$dns\" $disabled>"
	    echo "<h5>Forzar link a 100 Mbps full duplex:<br> (solo cuando haya problemas de cableado)<br>"
	    if [ "$forcelink" == "true" ]; then
		checked="checked"
	    else
		checked=""
	    fi
	    echo "	<input type='checkbox' name='nforcelink' value='true' $checked></h5>"
	    echo "<h5>Forzar cambio de MAC:<br> (solo cuando haya problemas de asignacion de IP)<br>"                                           
            if [ "$changemac" == "true" ]; then                                                                                                       
                checked="checked"                                                                                                                     
            else                                                                                                                                      
                checked=""                                                                                                                            
            fi                                                                                                                                        
            echo "      <input type='checkbox' name='nchangemac' value='true' $checked>" 
            echo "<br><input type='submit' value='Cambiar'></h5>"
            echo "</form></td></tr>"
        ;;
        "Proxy" )
            get_proxy
            get_proxy_exceptions
            get_parm action && [ "$action" == "setproxy" ] && get_parm nproxy && get_parm npexc && set_pexc $npexc && set_proxy $nproxy && proxy=`echo -e $( echo $nproxy | sed -e 's/+/ /g;s/%\(..\)/\\\x\1/g;' )` && pexceptions=`echo -e $( echo $npexc | sed -e 's/+/ /g;s/%\(..\)/\\\x\1/g;' )`
            [ "$action" == "unsetproxy" ] && set_pexc && set_proxy && proxy="" && pexceptions=""
            echo "<tr class='config'><td class='left' width='20%'><a href=\"?configuracion=1&${1}=1\"><h5>Proxy del terminal</h5></td>"
            echo "<td class='left'><form name='codigo' action='?configuracion=1&proxy=1' method='get'>"
            echo "<input type='hidden' name='configuracion' value='1'>"
            echo "<input type='hidden' name='Proxy' value='1'>"
            echo "<input type='hidden' name='action' value='setproxy'>"
            echo "<h5>Direcci&oacute;n y puerto del Proxy:<br><input type='text' name='nproxy' value=\"$proxy\"></h5>"
            echo "<h5>Excepciones del Proxy:<br><input type='text' name='npexc' value=\"$pexceptions\">"
            echo "<br><input type='submit' value='Cambiar'></h5>"
            echo "</form>"
            echo "<form name='codigo' action='?configuracion=1&proxy=1' method='get'>"
            echo "<input type='hidden' name='configuracion' value='1'>"
            echo "<input type='hidden' name='Proxy' value='1'>"
            echo "<input type='hidden' name='action' value='unsetproxy'>"
            echo "<h5><input type='submit' value='Desactivar proxy'></h5>"
            echo "</form></td></tr>"

        ;;
	"Impresion" )
	    get_printertype
	    get_parm action && [ "$action" == "setprintertype" ] && get_parm nprintertype && set_printertype $nprintertype && printertype=$nprintertype
            echo "<tr><td class='left headcolor' colspan='2'><h4>Impresi&oacute;n del terminal</h4></td></tr>"                                                 
            echo "<tr class='config'><td class='left' width='20%'><a href=\"?configuracion=1&${1}=1\">"                                               
            echo "    <h5>Modo de Impresi&oacute;n del terminal</h5></td>"                                                                                 
            echo "<td class='left'><form name='impresion' action='?configuracion=1&impresion=1' method='get'>"                                      
            echo "<input type='hidden' name='configuracion' value='1'>"                                                                               
            echo "<input type='hidden' name='Impresion' value='1'>"                                                                                  
            echo "<input type='hidden' name='action' value='setprintertype'>"                                                                                 
            echo "<h5><select name='nprintertype'>"                                                                                      
            selected=""                                                                                                                               
            [ "$printertype" == "consulta" ] && selected=" selected"                                                                                    
            echo "  <option value='consulta'${selected}>Consulta</option>"                                                                              
            selected=""                                                                                                                               
            [ "$printertype" == "admision" ] && selected=" selected"                                                                                   
            echo "  <option value='admision'${selected}>Admision</option>"                                                                            
            echo "</select>"                                                                                                                     
            echo "<br><input type='submit' value='Cambiar'></h5>"                                                                                     
            echo "</form></td></tr>"                                                                                                                  
	;;
        * )
            echo "<br><h4>${1}</h4>"
            ;;
    esac
}

content() {
    case $1 in 
        "dashboard" )
            dashboard "$2" "$3" "$4";;
        "informacion" )
            informacion "$2" "$3" "$4";;
        "servicios" )
            servicios "$2" "$3" "$4";;
        "configuracion" )
            configuracion "$2" "$3" "$4";;
    esac
}

