/*

This interface defines the data handler for Clikpage

See the example markdown and database handlers in this folder. Create your own custom one as required and pass to the site Object per the demo.

*/

interface {

	function init(struct params={}) {

	}

	/**
	 * Get array of data IDs that match data set filter criteria
	 * 
	 * @site         Site struct
	 * @dataset      see notes. 
	 * @data         Replace {field} in the dataset with these values
	 */
	public array function getDataSet(
		required struct dataset
		) {

		
	}

	/**
	 * Get struct of data records
	 * 
	 * @ID     array of IDs (see getDataSet())
	 */
	public struct function getRecords(
		required array  ID
		) {

	}

	/**
	 * Get full record of data
	 * 
	 * @ID    record key
	 */
	public struct function getRecord(required string ID) {

		
		
	}


}