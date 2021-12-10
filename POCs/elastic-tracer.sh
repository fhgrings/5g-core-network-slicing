http_funcs=$(grep -oPr "(?<=func ).*(?=\(c \*gin.Context\))" .)

for fun in $http_funcs; do
    file=$(echo $fun | cut -d ":" -f 1)
    fun_name=$(echo $fun | cut -d ":" -f 2)

    sed -i "/func $fun_name/a span, _ := apm.StartSpan(c.Request.Context(), \"$fun_name\", \"request\")\ndefer span.End()" $file
done

