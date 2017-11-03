
public class MangoPillarSample {
	private double x, y, z;
	private int[] rawData;
	private int base;
	private double[] rawDataFloat;
	
	public MangoPillarSample(int[] rawData, int base) {
		if(rawData.length != 4) throw new IllegalArgumentException("rawData must be 4 samples, n=" + rawData.length);
		this.rawData = rawData;
		this.rawDataFloat = new double[4];
		for(int i=0; i<4; i++) {
			this.rawDataFloat[i] = (double)rawData[i]/(double)base;
		}
		quadCalculate();
	}
	
	public MangoPillarSample(double[] rawData) {
		if(rawData.length != 4) throw new IllegalArgumentException("rawData must be 4 samples, n=" + rawData.length);
		this.rawDataFloat = rawData;
		quadCalculate();
	}
	
	private void quadCalculate() {
		double sum = rawDataFloat[0] + rawDataFloat[1] + rawDataFloat[2] + rawDataFloat[3];
		x = ((rawDataFloat[0] + rawDataFloat[1]) - (rawDataFloat[2] + rawDataFloat[3]))/sum;
		y = ((rawDataFloat[0] + rawDataFloat[3]) - (rawDataFloat[2] + rawDataFloat[1]))/sum;
		z = sum/(4);
	}
	
	public double getX() {
		return x;
	}
	
	public double getY() {
		return y;
	}
	
	public double getZ() {
		return z;
	}
	
	public int[] getRawData() {
		return rawData.clone();
	}
	
	public double[] getRawDataFloat() {
		return rawDataFloat;
	}
}
