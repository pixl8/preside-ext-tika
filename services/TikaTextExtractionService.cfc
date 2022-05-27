/**
 * @singleton      true
 * @presideService true
 */
component  {

	property name="assetManagerService" inject="assetManagerService";
	property name="supportedFileTypes"  inject="coldbox:setting:tikaFileTypes";

// CONSTRUCTOR
	public any function init() {
		_registerBundle();

		return this;
	}

// PUBLIC METHODS
	public void function processAsset( required string assetId, string versionId="" ) {
		var text             = "";
		var filePathOrBinary = assetManagerService.getAssetBinary(
			  id                     = arguments.assetId
			, versionId              = arguments.versionId
			, getFilePathIfSupported = false
		);

		if ( IsNull( local.filePathOrBinary ) ) {
			return;
		}

		if ( IsBinary( filePathOrBinary ) ) {
			text = _extractTextFromBinary( filePathOrBinary );
		} else {
			text = _extractTextFromFile( filePathOrBinary );
		}

		if ( Len( text ) ) {
			if ( Len( Trim( arguments.versionId ) ) ) {
				$getPresideObject( "asset_version" ).updateData(
					  id                  = arguments.versionId
					, data                = { raw_text_content=text }
					, skipTikaInterceptor = true
				);
			} else {
				$getPresideObject( "asset" ).updateData(
					  id                  = arguments.assetId
					, data                = { raw_text_content=text }
					, skipTikaInterceptor = true
				);
			}
		}
	}

	public void function processAssetVersion( required string versionId ) {
		var versionRecord = $getPresideObject( "asset_version" ).selectData( id=arguments.versionId, selectFields=[ "asset" ] );

		if ( Len( versionRecord.asset ) ) {
			processAsset( assetId=versionRecord.asset, versionId=arguments.versionId );
		}
	}

	public boolean function fileTypeIsSupported( required string recordId, required string objectName ) {
		return $getPresideObject( arguments.objectName ).dataExists(
			  id           = arguments.recordId
			, extraFilters = [ { filter={ asset_type=supportedFileTypes } } ]
		);
	}

// PRIVATE HELPERS
	private string function _extractTextFromFile( filePath ) {
		try {
			var f      = CreateObject( "java", "java.io.File" ).init( arguments.filePath );
			var parsed = CreateObject( "java", "org.apache.tika.Tika", "org.apache.tika.TikaApp" ).parseToString( f );

			return parsed;
		} catch( any e ) {
			$raiseError( e );
		}

		return "";
	}

	private string function _extractTextFromBinary( fileBinary ) {
		try {
			var is     = CreateObject( "java", "java.io.ByteArrayInputStream" ).init( arguments.fileBinary );
			var parsed = CreateObject( "java", "org.apache.tika.Tika", "org.apache.tika.TikaApp" ).parseToString( is );

			return parsed;
		} catch( any e ) {
			$raiseError( e );
		}

		return "";
	}

	private void function _registerBundle() {
		var cfmlEngine = CreateObject( "java", "lucee.loader.engine.CFMLEngineFactory" ).getInstance();
		var osgiUtil   = CreateObject( "java", "lucee.runtime.osgi.OSGiUtil" );
		var lib        = ExpandPath( "/app/extensions/preside-ext-tika/services/tika-app-2.4.0.jar" );
		var resource   = cfmlEngine.getResourceUtil().toResourceExisting( getPageContext(), lib );

		osgiUtil.installBundle( cfmlEngine.getBundleContext(), resource, true );
	}

}