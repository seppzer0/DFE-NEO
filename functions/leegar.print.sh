#!/sbin/sh
my_print(){
# Задаю переменные
in_text="$1" # Передача всех символом в функцию
skipG="* "
tick=1
listT=0
all_char="${#in_text}" # Подсчет всех символов которые передаются в функцию
all_words2=$( 
    # Подсчет слов
    for word in $in_text; do listT=$((listT + 1)); done
    echo $((listT + 2))
) 

# Специальный аргумент для отмены симовла -, другими словами убирает первую линию и переходит сразу ко второй
! [ -z "$2" ] && [ "$2" = "selected" ] && first_line=false || first_line=true 

# Проверка на количество символов в тексте, если больше 50, то срабатывает обработчик, если меньше, то выводит текста сразу
if [ "$all_char" -gt 50 ]; then
    while true; do
        num=$(echo ${in_text%${in_text#$skipG}*} | wc -m)
        if [ "$num" -ge 45 ]; then
            [ "$num" -gt 55 ] && skipG="${skipG%\**}"
            $first_line && ui_print "- ${in_text%${in_text#$skipG}*}" || ui_print "  ${in_text%${in_text#$skipG}*}"
            in_text="${in_text#$skipG}"
            skipG="* "
            first_line=false
        else
            skipG="${skipG}* "
        fi
        tick=$((tick + 1))
        if [ "$tick" -ge "$all_words2" ]; then
            if [ -z "${in_text}" ] || [ "${in_text}" == " " ]; then
                ui_print " " && break
            else
                $first_line && ui_print "- ${in_text}" || ui_print "  ${in_text}"
            fi
            break
        fi
    done
else
    if [ -z "${in_text}" ] || [ "${in_text}" == " " ]; then
        ui_print " "
    else
        $first_line && ui_print "- ${in_text}" || ui_print "  ${in_text}"
    fi
fi
}