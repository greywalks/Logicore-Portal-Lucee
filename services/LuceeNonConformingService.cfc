component extends="services.NonConformingService" output=false {
    function init(required string datasource, required string outputPath) {
        variables.datasource = arguments.datasource;
        variables.outputPath = arguments.outputPath;
        variables.editableFields = ["ticket_no","model","serial","ra_no","tracking","carrier","address","status","ussi_resolution","addtl_info","origin_company","store_no","rack","bin"];
        variables.requiredFields = ["model","serial","carrier"];
        super.init();
        return this;
    }
}
