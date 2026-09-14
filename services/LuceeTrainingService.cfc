component extends="services.TrainingService" output=false {
    function init(required string datasource, required string rootPath) {
        variables.datasource = arguments.datasource;
        variables.rootPath = arguments.rootPath;
        variables.uploadPath = arguments.rootPath & "data/training_signoffs/";
        if (!directoryExists(variables.uploadPath)) directoryCreate(variables.uploadPath, true);
        super.init();
        return this;
    }
}
