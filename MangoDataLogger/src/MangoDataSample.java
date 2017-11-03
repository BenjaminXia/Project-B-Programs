
public class MangoDataSample {
	private boolean valid = false;
	private MangoPillarSample[] pillarData;
	private String additionalData = "";
	private int base;
	private String inputString;
	
	/*public MangoDataSample(byte[] inputData) {
		//parse input bytes
		int numPillars = 2; //(int)inputData[0];
		pillarData = new MangoPillarSample[numPillars];
		int pos = 1;
		for(int i=0; i<numPillars; i++) {
			int[] quadrantData = new int[4]; //data for each quadrant
			for(int k=0; k<4; k++) {
				byte msb = inputData[pos++];
				byte lsb = inputData[pos++];
				quadrantData[k] = (int)msb*128 + (int)lsb;
			}
			pillarData[i] = new MangoPillarSample(quadrantData);
		}
	}*/
	
	public MangoDataSample(String inputData) {
		this.inputString = inputData;
		//System.out.println("-" + inputData + "-");
		String[] strings = inputData.split("\t");
		int nPillars = Integer.parseInt(strings[0]);
		pillarData = new MangoPillarSample[nPillars];
		int pos = 1;
		if(strings.length < nPillars*4 + 2) return;
		base = Integer.parseInt(strings[pos++]);
		for(int i=0; i<nPillars; i++) {
			int[] quadrantData = new int[4]; //data for each quadrant
			for(int k=0; k<4; k++) {
				quadrantData[k] = Integer.parseInt(strings[pos++]);
			}
			pillarData[i] = new MangoPillarSample(quadrantData, base);
		}
		if(strings.length > nPillars*4 + 1) {
			while(pos < strings.length) {
				additionalData += "\t" + strings[pos++];
			}
		}
		valid = true;
	}
	
	public int getPillarCount() {
		return pillarData.length;
	}
	
	public MangoPillarSample getPillarData(int i) {
		return pillarData[i];
	}
	
	public boolean isValid() {
		return valid;
	}
	
	public String generateLogLine() {
		/*String line = "";
		for(int pillar=0; pillar<pillarData.length; pillar++) {
			for(int i=0; i<4; i++) {
				if(!(pillar == 0 && i == 0)) line += "\t";
				line += pillarData[pillar].getRawData()[i];
			}
		}
		line += additionalData;
		return line;*/
		return inputString;
	}
}
