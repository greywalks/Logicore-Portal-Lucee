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
    this.javaSettings = {loadPaths:[variables.rootPath & "lib"],loadColdFusionClassPath:true,reloadOnChange:false};
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
        application.auth = new services.LuceeAuthService(datasource="logicore");
        application.configService = new services.ConfigService(rootPath=application.rootPath);
        application.outputs = new services.OutputService(outputPath=application.outputPath);
        application.nonconforming = new services.LuceeNonConformingService(datasource="logicore", outputPath=application.outputPath, excelService=application.excel);
        application.invoice = new services.InvoiceService(
            rootPath=application.rootPath,
            uploadPath=application.uploadPath,
            outputPath=application.outputPath,
            configService=application.configService,
            outputService=application.outputs,
            excelService=application.excel
        );
        application.philipsReport = new services.PhilipsReportService(excelService=application.excel, configService=application.configService, outputPath=application.outputPath);
        application.trainingPdf = new services.TrainingPdfService();
        application.training = new services.LuceeTrainingService(datasource="logicore", rootPath=application.rootPath, excelService=application.excel);
        application.inventory = new services.InventoryService(datasource="logicore", rootPath=application.rootPath, excelService=application.excel);
        application.inventory.bootstrap();

        application.outputs.cleanOld(72);
        return true;
    }

    boolean function onRequestStart(string targetPage) {
        var requestPath=listFirst(cgi.request_uri?:"/","?");
        var isCI=createObject("java","java.lang.System").getenv("CI")=="true";
        var internal=reFindNoCase("^/(data|uploads|outputs|services|routes|config|migration|template)/",requestPath)||reFindNoCase("^/(Application\.cfc|server\.json|\.CFConfig\.json|MIGRATION_PARITY\.md|README\.md)$",requestPath);
        var ciFixture=isCI&&requestPath=="/tests/billing_parity.cfm";
        if((internal||left(requestPath,7)=="/tests/")&&!ciFixture){
            var response=getPageContext().getResponse();response.setStatus(404);response.setContentType("text/plain; charset=utf-8");writeOutput("Not Found");return false;
        }
        if (isCI && structKeyExists(url, "reload") && url.reload == "1") onApplicationStart();
        if (!structKeyExists(session, "sid")) session.sid = replace(createUUID(), "-", "", "all");
        return true;
    }

    void function onError(any exception, string eventName) {
        var detail = (exception.message ?: "") & " | " & (exception.detail ?: "");
        writeLog(type="error", file="logicore", text=detail);
        if (!isDefined("request.responseCommitted") || !request.responseCommitted) {
            cfheader(statusCode=500, statusText="Internal Server Error");
            var isCI = createObject("java","java.lang.System").getenv("CI") == "true";
            writeOutput(isCI ? "Logicore CI error: " & detail : "Logicore Portal encountered an unexpected error.");
        }
    }
}
