component output=false {
    variables.rootPath = getDirectoryFromPath(getCurrentTemplatePath());

    this.name = "LogicorePortalLucee";
    this.applicationTimeout = createTimeSpan(1, 0, 0, 0);
    this.sessionManagement = true;
    this.sessionTimeout = createTimeSpan(0, 8, 0, 0);
    this.setClientCookies = true;
    this.sessionCookie = {httpOnly:true, secure:false, sameSite:"Lax"};
    this.scriptProtect = "all";
    this.datasource = "logicore";
    this.datasources["logicore"] = {
        class: "org.h2.Driver",
        connectionString: "jdbc:h2:file:" & replace(variables.rootPath, "\\", "/", "all") & "data/logicore;MODE=LEGACY;DATABASE_TO_UPPER=FALSE;AUTO_SERVER=TRUE",
        username: "sa",
        password: ""
    };

    boolean function onApplicationStart() {
        application.rootPath = variables.rootPath;
        application.uploadPath = application.rootPath & "uploads/";
        application.outputPath = application.rootPath & "outputs/";
        application.dataPath = application.rootPath & "data/";
        application.configPath = application.rootPath & "config/";
        application.signoffPath = application.dataPath & "training_signoffs/";

        for (var dirPath in [application.uploadPath, application.outputPath, application.dataPath, application.configPath, application.signoffPath]) {
            if (!directoryExists(dirPath)) directoryCreate(dirPath, true);
        }
        if (!directoryExists(application.outputPath & ".access/")) directoryCreate(application.outputPath & ".access/", true);

        application.excel = new services.ExcelService();
        application.auth = new services.AuthService(datasource="logicore");
        application.configService = new services.ConfigService(rootPath=application.rootPath);
        application.outputs = new services.OutputService(outputPath=application.outputPath);
        application.nonconforming = new services.NonConformingService(datasource="logicore", outputPath=application.outputPath);
        application.invoice = new services.InvoiceService(
            rootPath=application.rootPath,
            uploadPath=application.uploadPath,
            outputPath=application.outputPath,
            configService=application.configService,
            outputService=application.outputs,
            excelService=application.excel
        );
        application.training = new services.TrainingService(datasource="logicore", rootPath=application.rootPath);

        application.auth.init();
        application.nonconforming.init();
        application.training.init();
        application.outputs.cleanOld(72);
        return true;
    }

    boolean function onRequestStart(string targetPage) {
        if (structKeyExists(url, "reload") && url.reload == "1") onApplicationStart();
        if (!structKeyExists(session, "sid")) session.sid = replace(createUUID(), "-", "", "all");
        return true;
    }

    void function onError(any exception, string eventName) {
        writeLog(type="error", file="logicore", text=exception.message & " | " & exception.detail);
        if (!isDefined("request.responseCommitted") || !request.responseCommitted) {
            cfheader(statusCode=500, statusText="Internal Server Error");
            writeOutput("Logicore Portal encountered an unexpected error.");
        }
    }
}
