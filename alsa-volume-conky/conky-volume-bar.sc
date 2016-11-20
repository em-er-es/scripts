 ${color Green2}${exec amixer -c PCH sget Master | awk '/dB/{x = $5; y = substr(x, 2, length(x)-7); z = (sqrt(y^2) + sqrt(z^2))/i; i++;} BEGIN{i = 1;} END{print "-" z "dB";}'}\
 ${color Green2}${exec amixer -c PCH sget Master | awk '/dB/{x = $4; y = substr(x, 2, length(x)-2); z = (y + z)/i; i++;} BEGIN{i = 1;} END{print z "%";}'} \
