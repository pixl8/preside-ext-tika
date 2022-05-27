component {

	property name="tikaTextExtractionService" inject="tikaTextExtractionService";

	/**
	 * Helper handler for action that will run in an adhoc task
	 * background thread
	 *
	 */
	private boolean function processAsset( event, rc, prc, args={} ) {
		if ( ( args.objectName ?: "" ) == "asset_version" ) {
			tikaTextExtractionService.processAssetVersion( args.recordId ?: "" );
		} else {
			tikaTextExtractionService.processAsset( args.recordId ?: "" );
		}

		return true;
	}


}