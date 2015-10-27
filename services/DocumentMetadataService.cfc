/**
 * @singleton
 */
component displayName="Apache Tika Wrapper" extends="preside.system.services.assetManager.DocumentMetadataService" {

// CONSTRUCTOR
	public any function init() {
		super.init( argumentCollection=arguments );

		_setTikaJarPath( GetDirectoryFromPath( GetCurrentTemplatePath( ) ) & "tika-app-1.2.jar" );

		return this;
	}

// PRIVATE HELPERS (this is the only method we need to override to make all this work)
	private struct function _parse( required any fileContent, boolean includeMeta=true, boolean includeText=true ) {
		var result  = {};
		var is      = "";
		var jarPath = _getTikaJarPath();

		if ( IsBinary( arguments.fileContent ) ) {
			is = CreateObject( "java", "java.io.ByteArrayInputStream" ).init( arguments.fileContent );
		} else {
			// TODO, support plain string input (i.e. html)
			return {};
		}

		try {
			var parser = CreateObject( "java", "org.apache.tika.parser.AutoDetectParser", jarPath );
			var ch     = CreateObject( "java", "org.apache.tika.sax.BodyContentHandler" , jarPath ).init(-1);
			var md     = CreateObject( "java", "org.apache.tika.metadata.Metadata"      , jarPath ).init();

			parser.parse( is, ch, md );

			if ( arguments.includeMeta ) {
				result.metadata = {};

				for( var key in md.names() ) {
					var mdval = md.get( key );
					if ( !isNull( mdval ) ) {
						result.metadata[ key ] = _removeNonUnicodeChars( mdval );
					}
				}
			}

			if ( arguments.includeText ) {
				result.text = _removeNonUnicodeChars( ch.toString() );
			}

		} catch( any e ) {
			result = { error = e };
		}

		return result;
	}

	private string function _removeNonUnicodeChars( required string potentiallyDirtyString ) {
		return ReReplace( arguments.potentiallyDirtyString, "[^\x20-\x7E]", "", "all" );
	}

// GETTERS AND SETTERS
	private string function _getTikaJarPath() {
		return _tikaJarPath;
	}
	private void function _setTikaJarPath( required string tikaJarPath ) {
		_tikaJarPath = arguments.tikaJarPath;
	}

}