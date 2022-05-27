component {

	public void function configure( required struct config ) {
		var conf     = arguments.config;
		var settings = conf.settings ?: {};

		_setupExtensionSettings( settings );
		_setupInterceptors( conf );
	}

// helpers
	private void function _setupExtensionSettings( settings ) {
		settings.tikaFileTypes = [ "pdf" ]; // potentially support more, or add documentation for how to set - or set dynamically through admin
	}

	private void function _setupInterceptors( conf ) {
		conf.interceptors.append( {
			  class      = "app.extensions.preside-ext-tika.interceptors.TikaInterceptors"
			, properties = {}
		} );

	}

}