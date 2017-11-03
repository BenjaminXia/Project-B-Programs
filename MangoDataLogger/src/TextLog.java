import java.io.FileNotFoundException;
import java.io.PrintWriter;
import java.util.ArrayList;

public class TextLog {
	private ArrayList<String>strings;
	private long startTime;
	private boolean isLogging;
	
	public TextLog() {
		
	}
	
	public void start() {
		strings = new ArrayList<String>();
		startTime = System.currentTimeMillis();
	}
	
	public void add(String line) {
		strings.add(line);
	}
	
	public boolean save(String filename) {
		try {
			PrintWriter writer = new PrintWriter(filename);
			for(String s:strings) {
				writer.println(s);
			}
			writer.close();
		} catch (FileNotFoundException e) {
			e.printStackTrace();
			return false;
		}
		return true;
	}
	
	public long getTime() {
		return System.currentTimeMillis() - startTime;
	}
	
	public boolean isLogging() {
		return isLogging;
	}
	
	public int getSampleCount() {
		return strings.size() - 1;
	}
	
}
