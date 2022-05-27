component extends="coldbox.system.Interceptor" {

	property name="adhocTaskmanagerService"   inject="delayedInjector:adhocTaskmanagerService";
	property name="tikaTextExtractionService" inject="delayedInjector:tikaTextExtractionService";
	property name="systemConfigurationService" inject="delayedInjector:systemConfigurationService";

	public void function configure() {}

	public void function postInsertObjectData( event, interceptData ) {
		if ( StructKeyExists( arguments.interceptData, "skipTika" ) ) {
			return;
		}

		var objectname = interceptData.objectname ?: "";

		if ( objectName == "asset" or objectName == "asset_version" ) {
			_processAsset( interceptData.newId ?: "", objectName );
		}
	}

	public void function postUpdateObjectData( event, interceptData ) {
		if ( StructKeyExists( arguments.interceptData, "skipTika" ) ) {
			return;
		}

		var objectname = interceptData.objectname ?: "";
		if ( objectName == "asset" or objectName == "asset_version" && Len( interceptData.changedData.storage_path ?: "" ) ) {
			_processAsset( interceptData.id ?: "", objectName );
		}
	}

// helpers
	private void function _processAsset( recordId, objectName ){
		if ( Len( Trim( arguments.recordId ) ) && _readMetaEnabled() && tikaTextExtractionService.fileTypeIsSupported( argumentCollection=arguments ) ) {
			adhocTaskmanagerService.createTask(
				  event             = "tika.processAsset"
				, args              = { recordId=arguments.recordId, objectName=arguments.objectName }
				, runNow            = true
				, discardOnComplete = true
			);
		}
	}

	/**
	 * Perhaps this should be revisited. This setting is about metadata rather than text.
	 * We could have our own system config to enable tika extraction and perhaps to choose
	 * the filetypes we want to support it for...
	 *
	 */
	private boolean function _readMetaEnabled() {
		var setting = systemConfigurationService.getSetting( "asset-manager", "retrieve_metadata" );

		return IsBoolean( setting ) && setting;
	}


}