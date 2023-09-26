#!/bin/bash

trap 'rm -f "$TMPPLIK"' EXIT	      #usun pliki tymczasowe przy EXIT	
TMPPLIK=$(mktemp) || exit 1           #stworz plik tymczasowy lub wyjdz z kodem 1
trap 'clear ' SIGINT SIGHUP SIGILL SIGQUIT SIGTERM	#wyczysc ekran przy sygnalach

i=
j=
SCIEZKA=/
WYBOR=
WYSZUKANIE=
NAZWAPLIKU=
SCIEZKAPLIKU=
NUMER=
TAB=() 				# definicja tablicy 1
TABLICAW=() 				# definicja tablicy 2


#Pomoc do skryptu
function pomoc {

echo 'Uzycie mffap.sh [opcja][parametr]

Wyszukiwarka i odtwazacz plikow multimedialnych. Skrypt przeszuka dyski od korzenia (domyslne ustawienie) 
lub rozpoczynajac od wybranej sciezki i odnajdzie pliki multimedialne w formatach:
	graficznych - jpg, gif, ico, bmp, jpeg, png, tiff. 
	video - avi, mpg, mpeg, mp4, mkv, wmv, wmf. 
	dzwiekowych - mp3, wav, mpg, mpeg, mp2, mp4, wma. 

Do wyszukiwania plikow nalezy wpisac nazwe skryptu, ktora mozna uzupelnic podajac opcje.

[opcja]:

-v             wyswietlenie wersji skryptu
-a	       wyswietlenie danych o autorze
-p path        szukanie plikow w dol od podanej sciezki (parametr path)
-n name        szukaj plikow zawierajacych w nazwach slowa lub ich czesci (parametr name)
-h             wyswietl pomoc

Do poprawnego dzialania skryptu potrzebne sa programy dialog, eog, vlc (wraz z kodekami)'
exit
}

#O autorze i licencji
function autor {
echo 'Michal Scibisz 178201 - wszelkie prawa zastrzezone'
exit
}

#Nr wersji i dodane zmiany
function wersja {
echo "
mffap wersja 1.03 

HISTORIA ZMIAN:
"
echo 'wersja 1.03 - poprawiono formule regex - dodano znak $ na koniec grupy rozszerzenia pliku	- 02.06.2020'
echo 'wersja 1.02 - poprawiono literowki oraz opcje -h, ulepszono filtr nazwy pliku 			- 31.05.2020'
echo 'wersja 1.01 - dodano funkcje help, autor, wersja, przetestowano bledy wprowadzania		- 30.05.2020'
echo 'wersja 1.00 - ukonczono glowny szkielet programu						- 29.05.2020'
echo 'wersja 0.01 - rozpoczeto prace, ukonczono pierwsze okno dialogowe				- 26.05.2020'
exit
}

#Pozegnanie i wyjscie
function byebye() { dialog --backtitle "mffap  - multimedia files finder and player" \
	                   --no-ok --no-cancel \
			   --title "BYE BE" \
			   --pause "Do zobaczenia" 8 34 1 ; 
		   clear ;          #Czekaj 1 sek
		   exit ;
}

#Komunikat oczekiwania
function czekaj() { dialog --backtitle "mffap  - multimedia files finder and player" \
	                   --infobox "\n Prosze czekac" 0 0 ; 		
}

#Komunikat braku dopasowania
function nieznaleziono() { dialog --backtitle "mffap  - multimedia files finder and player" \
	                   --no-ok --no-cancel \
			   --title "File not found" \
			   --pause "Nie znaleziono zadnych pasujacych plikow lub anulowano" 8 34 1 ; 
		   clear ;          #Czekaj 1 sek
		   exit ;
}

#uzycie getopts  
while getopts "vap:n:h" OPT; do   
   case $OPT in
	v)
	   wersja;;         
	a)
	   autor;;	
	p)
	   if [ -d $OPTARG ]; then 
		SCIEZKA=$OPTARG
	   else 
		dialog     --backtitle "mffap  - multimedia files finder and player" \
	                   --infobox "\n Podano bledna sciezke, wyszukanie zacznie sie od katalogu glownego" 0 0 ; 
		sleep 2 	  
           fi  ;;
	n) 	  				    
	   NAZWAPLIKU=$(echo $OPTARG | grep -E "[^(\\/:\"*?<>|)]+" ) ;; # pliki o nazwach pod windows, bez .. czy innych wyjatkow 
        h)
           pomoc ;;	
	?) 
	   echo "Podaj prawidlowa opcje"; 
           exit;; 
      esac
done




dialog             --backtitle "mffap  - multimedia files finder and player" \
                   --title "Wybierz typ pliku multimedialnego" \
                   --radiolist " \n <UP> <DOWN> <LEFT> <RIGHT> aby nawigowac 
	   			 \n <SPACE> aby dokonac selekcji 
	   			 \n <ENTER> aby potwierdzic wybor
	  			 \n." 16 71 5 \
                   "foto"     "wyszukiwanie i pokazywanie zdjec" on\
		   "video"    "wyszukiwanie i odtwarzanie filmow " off\
                   "dzwiek"   "wyszukiwanie i odtwarzanie muzyki oraz dzwiekow" off  2> $TMPPLIK
                   
case $? in 
  0) 
     	clear
        WYBOR=`cat $TMPPLIK`
	dialog  --backtitle "mffap  - multimedia files finder and player" \
                --title "Podaj sciezke od ktorej zacznie sie wyszukanie plikow."\
                --dselect  $SCIEZKA 14 70 2> $TMPPLIK					# Directory select   
	  
	    if [ $? -eq 0 ]; then		
	    	 SCIEZKA=`cat $TMPPLIK`
	    	 if [ ! -d $SCIEZKA ]; then
	        	clear
			dialog     --backtitle "mffap  - multimedia files finder and player" \
	                   --infobox "\n Podano bledna sciezke" 0 0 
			sleep 1 		        
			byebye	    
	    	  fi		        
             else
                  clear
		  byebye  	     
	     fi
	        
	dialog     --backtitle "mffap  - multimedia files finder and player" \
                   --title "Enter file name"\
                   --inputbox "\nPodaj nazwe pliku lub nacisnij enter aby wyszukac wszystkie pliki. " 12 60 "$NAZWAPLIKU"   2> $TMPPLIK 
	
	if [ $? -eq 0 ]; then										# Exit przez OK
    	    NAZWAPLIKU=`cat $TMPPLIK` 
	    NAZWAPLIKU=$(echo $NAZWAPLIKU | grep -E "[^(\\/:\"*?<>|)]+" ) ;   		#tych znakow nie wolno w nazwie
	else
	        clear
	        byebye	    
	fi         
	
	case $WYBOR in   
	   
		foto)
		       dialog         	--backtitle "mffap  - multimedia files finder and player" \
                   			--title "Wybierz rozszerzenie pliku multimedilnego" \
                   			--checklist "\n <UP> <DOWN> <LEFT> <RIGHT> aby nawigowac 
	   					     \n <SPACE> aby dokonac selekcji 
	   			                     \n <ENTER> aby potwierdzic wybor
	  			                     \n." 20 71 9 \
                   			"jpg"     "" on\
		   			"gif"     "" off\
		   			"bmp"     "" on\
		   			"jpeg"     "" off\
		   			"ico"     "" on\
		   			"png"    "" off\
                   			"tiff"     "" off  2> $TMPPLIK
	
			if [[ $? -ne 0 ]]; then 
			    clear
			    byebye
			fi  
		
			sed -i.bak 's#\(.*\)#\1\ #g' $TMPPLIK     #dodanie spacji na koniec    				
			while read -d ' ' WORD; do                #spacja ustawiona jako delimiter, wczytywanie zaznaczonych rozszerzen do tablicy 
   	  	  	   TAB+=( $WORD)
			done < $TMPPLIK		         
			
			czekaj	
			find $SCIEZKA -iregex ".*${NAZWAPLIKU}.*\.\(${TAB[0]}\|${TAB[1]}\|${TAB[2]}\|${TAB[3]}\|${TAB[4]}\|${TAB[5]}\|${TAB[6]}\)$" \
			 > $TMPPLIK 2>/dev/null 
									#szukanie plikow spelniajacych kryteria i zapisanie wyniku w pliku tymczasowym
				
			let i=0 				#zmienna "i" ktorej przypisze numer wiersza 
			while read -r LINE; do 		#wczytuj linie.....
 			    let i=$i+1				#zwieksz zmienna "i"
    			    TABLICAW+=($i "$LINE")		#dopisz do tablicy
			done < $TMPPLIK			#.....z pliku tymczasowego

			NUMER=$(dialog --title "Wybierz plik, ktory chcesz obejrzec" --menu \
					"\n <UP> <DOWN> <LEFT> <RIGHT> aby nawigowac 
	   			        \n <SPACE> aby dokonac selekcji 
	   			        \n <ENTER> aby potwierdzic wybor
	  			        \n." 24 80 17 "${TABLICAW[@]}" 3>&2 2>&1 1>&3 ) #zamien strumienie i zapisz w zmiennej NUMER swoj wybor	
									
                        if [ $? -eq 0 ]; then	# Exit przez OK
			     clear
    			     czekaj
                             WYSZUKANIE=$(find $SCIEZKA -iregex ".*${NAZWAPLIKU}.*\.\(${TAB[0]}\|${TAB[1]}\|${TAB[2]}\|${TAB[3]}\|${TAB[4]}\|${TAB[5]}\|${TAB[6]}\)$" \
			     2>/dev/null | sed -n "`echo "$NUMER{p}"`")
			                                                                # drukuj tylko i wylacznie linie o numerze rownym $NUMER
  			 
			     NAZWAPLIKU=$(echo $WYSZUKANIE | sed 's#.*\/##g')		# uzyskaj sama nazwe pliku
			     echo "$NAZWAPLIKU" | sed -n 's#\ #\\ #g'			# zastap "<spacja>" przez "\<spacja>" - potrzebne dla nazw wielowyrazowych
			     SCIEZKAPLIKU=$(echo $WYSZUKANIE | sed 's#\(.*\)/.*#\1#g')	# uzyskaj sama sciezke pliku
			
			     eog "$SCIEZKAPLIKU/$NAZWAPLIKU"				# uruchom przegladarke EOG z wybranym plikiem 
			     clear
					
			else
			    clear ; 
			    nieznaleziono				
		        fi ;;	         # finish foto)

	    video) 
		        dialog        	--backtitle "mffap  - multimedia files finder and player" \
                   			--title "Wybierz rozszerzenie pliku multimedilnego"  \
                   			--checklist "\n <UP> <DOWN> <LEFT> <RIGHT> aby nawigowac 
	   					     \n <SPACE> aby dokonac selekcji 
	   			                     \n <ENTER> aby potwierdzic wybor
	  			                     \n." 20 71 9 \
                   			"mpg"     "" on\
		   			"wmf"     "" off\
		   			"avi"     "" on\
		   			"wmv"     "" off\
		   			"mkv"     "" on\
		   			"mpeg"    "" off\
                   			"mp4"     "" off  2> $TMPPLIK
				
			if [[ $? -ne 0 ]]; then 
			    clear
			    bybye
			fi  
				
			sed -i.bak 's#\(.*\)#\1\ #g' $TMPPLIK   #dodanie spacji na koniec    				
			while read -d ' ' WORD; do              #spacja ustawiona jako delimiter, wczytywanie do tablicy zaznaczonych rozszerzen
			    TAB+=( $WORD)
			done < $TMPPLIK 		         
			
			czekaj				
			find $SCIEZKA -iregex ".*${NAZWAPLIKU}.*\.\(${TAB[0]}\|${TAB[1]}\|${TAB[2]}\|${TAB[3]}\|${TAB[4]}\|${TAB[5]}\|${TAB[6]}\)$" \
			 > $TMPPLIK 2>/dev/null 
									#szukanie plikow spelniajacych kryteria i zapisanie wyniku w pliku tymczasowym

			let i=0 				#zmienna "i" ktorej przypisze numer wiersza 
			while read -r LINE; do 		#wczytuj linie.....
 			    let i=$i+1				#zwieksz zmienna "i"
    			    TABLICAW+=($i "$LINE")		#dopisz do tablicy
			done < $TMPPLIK			#.....z pliku tymczasowego

			NUMER=$(dialog --title "Wybierz plik, ktory chcesz odtworzyc" --menu \
				"\n <UP> <DOWN> <LEFT> <RIGHT> aby nawigowac 
	   		        \n <SPACE> aby dokonac selekcji 
	   		        \n <ENTER> aby potwierdzic wybor
	  		        \n." 24 80 17 "${TABLICAW[@]}" 3>&2 2>&1 1>&3 ) #zamien strumienie i zapisz w zmiennej NUMER swoj wybor	

                       if [ $? -eq 0 ]; then	# Exit przez OK
			     clear
    			     czekaj
                             WYSZUKANIE=$(find $SCIEZKA -iregex ".*${NAZWAPLIKU}.*\.\(${TAB[0]}\|${TAB[1]}\|${TAB[2]}\|${TAB[3]}\|${TAB[4]}\|${TAB[5]}\|${TAB[6]}\)$" \
			     2>/dev/null | sed -n "`echo "$NUMER{p}"`")
			                                                                	# drukuj tylko i wylacznie linie o numerze rownym $NUMER
  			 
			     NAZWAPLIKU=$(echo $WYSZUKANIE | sed 's#.*\/##g')			# uzyskaj sama nazwe pliku
			     echo "$NAZWAPLIKU" | sed -n 's#\ #\\ #g'				# zastap "<spacja>" przez "\<spacja>" - potrzebne dla nazw wielowyrazowych
			     SCIEZKAPLIKU=$(echo $WYSZUKANIE | sed 's#\(.*\)/.*#\1#g')		# uzyskaj sama sciezke pliku
			
			     vlc  "$SCIEZKAPLIKU/$NAZWAPLIKU"					# uruchom odtwarzacz VLC z wybranym plikiem
			     clear 
					
			else
			     clear ; 
			     nieznaleziono				
		        fi ;;	         # finish video)
		       
			
	    dzwiek)
		        dialog        	--backtitle "mffap  - multimedia files finder and player" \
                   			--title "Wybierz rozszerzenie pliku multimedilnego"  \
                   			--checklist "\n <UP> <DOWN> <LEFT> <RIGHT> aby nawigowac 
	   					     \n <SPACE> aby dokonac selekcji 
	   			                     \n <ENTER> aby potwierdzic wybor
	  			                     \n." 20 71 9 \
                   			"mp3"     "" on\
		   			"wav"     "" off\
		   			"wma"     "" on\
		   			"mpeg"    "" off\
		   			"mpg"     "" on\
		   			"mp2"     "" off\
                   			"mp4"     "" off  2> $TMPPLIK
				
			if [[ $? -ne 0 ]]; then 
			    clear
			    byebye
			fi  
				
			sed -i.bak 's#\(.*\)#\1\ #g' $TMPPLIK   #dodanie spacji na koniec    				
			while read -d ' ' WORD; do              #spacja ustawiona jako delimiter, wczytywanie do tablicy zaznaczonych rozszerzen
			    TAB+=( $WORD)
			done < $TMPPLIK 		         
			
			czekaj				
			find $SCIEZKA -iregex ".*${NAZWAPLIKU}.*\.\(${TAB[0]}\|${TAB[1]}\|${TAB[2]}\|${TAB[3]}\|${TAB[4]}\|${TAB[5]}\|${TAB[6]}\)$" \
			 > $TMPPLIK 2>/dev/null 
									#szukanie plikow spelniajacych kryteria i zapisanie wyniku w pliku tymczasowym

			let i=0 				#zmienna "i" ktorej przypisze numer wiersza 
			while read -r LINE; do 		#wczytuj linie.....
 			    let i=$i+1				#zwieksz zmienna "i"
    			    TABLICAW+=($i "$LINE")		#dopisz do tablicy
			done < $TMPPLIK			#.....z pliku tymczasowego

			NUMER=$(dialog --title "Wybierz plik, ktory chcesz odtworzyc" --menu \
				"\n <UP> <DOWN> <LEFT> <RIGHT> aby nawigowac 
	   		        \n <SPACE> aby dokonac selekcji 
	   		        \n <ENTER> aby potwierdzic wybor
	  		        \n." 24 80 17 "${TABLICAW[@]}" 3>&2 2>&1 1>&3 ) #zamien strumienie i zapisz w zmiennej NUMER swoj wybor	

                       if [ $? -eq 0 ]; then	# Exit przez OK
			     clear
    			     czekaj
                             WYSZUKANIE=$(find $SCIEZKA -iregex ".*${NAZWAPLIKU}.*\.\(${TAB[0]}\|${TAB[1]}\|${TAB[2]}\|${TAB[3]}\|${TAB[4]}\|${TAB[5]}\|${TAB[6]}\)$" \
			     2>/dev/null | sed -n "`echo "$NUMER{p}"`")
			                                                                	# drukuj tylko i wylacznie linie o numerze rownym $NUMER
  			 
			     NAZWAPLIKU=$(echo $WYSZUKANIE | sed 's#.*\/##g')			# uzyskaj sama nazwe pliku
			     echo "$NAZWAPLIKU" | sed -n 's#\ #\\ #g'				# zastap "<spacja>" przez "\<spacja>" - potrzebne dla nazw wielowyrazowych
			     SCIEZKAPLIKU=$(echo $WYSZUKANIE | sed 's#\(.*\)/.*#\1#g')		# uzyskaj sama sciezke pliku
			
			     vlc --no-video "$SCIEZKAPLIKU/$NAZWAPLIKU"			# uruchom odtwarzacz VLC z wybranym plikiem (w trybie audio / no video)
			     clear
					
			else
			     clear ; 
			     nieznaleziono				
		        fi ;;	         # finish dzwiek)
        esac ;;    # finish case WYBOR 
  1) 
	clear        
	byebye ;;
  255) 
	clear         
	byebye ;;
  *) 
	clear         
	byebye ;;
esac	
