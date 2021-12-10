http_funcs=$(grep -oPr "router := logger_util.NewGinWithLogrus" .)

for fun in $http_funcs; do
    file=$(echo $fun | cut -d ":" -f 1)
    router=$(echo $fun | cut -d ":" -f 2)

    nf_name=$(echo $file | cut -d "/" -f 2)
    if ! [[ $file == *"init.go"* ]]; then continue ; fi
    
    sed -i "/$router := logger_util/a \
      	opts := \[\]pinpoint.ConfigOption{ \n\
		pinpoint.WithAppName(\"$nf_name-go\"), \n\
        pinpoint.WithAgentId(\"$nf_name-go-agent\"), \n\
   		pinpoint.WithCollectorHost(\"localhost\"),\n \
	} \n\
	cfg, _ := pinpoint.NewConfig(opts...) \n\
	agent, err := pinpoint.NewAgent(cfg) \n\
	if err != nil { \n\
		log.Fatalf(\"pinpoint agent start fail: %v\", err) \n\
	} \n\
	router.Use(pgin.Middleware(agent))" $file

	sed -i '/import (/a \
	_ "github.com/pinpoint-apm/pinpoint-go-agent" \
	pgin "github.com/pinpoint-apm/pinpoint-go-agent/plugin/gin"' $file
done

