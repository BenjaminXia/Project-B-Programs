import java.awt.BorderLayout;
import java.awt.Dimension;
import java.awt.FlowLayout;
import java.awt.GridLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.File;
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.concurrent.TimeUnit;
import java.util.prefs.Preferences;

import javax.swing.BoxLayout;
import javax.swing.JButton;
import javax.swing.JCheckBox;
import javax.swing.JComboBox;
import javax.swing.JFileChooser;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JTextField;
import javax.swing.UIManager;

import com.fazecast.jSerialComm.SerialPort;
import com.fazecast.jSerialComm.SerialPortDataListener;
import com.fazecast.jSerialComm.SerialPortEvent;
import com.sun.org.apache.bcel.internal.generic.ISHL;

import arduino.*;

public class MangoLoggerGuiV2 {
	private Preferences preferences;
	
	private JFrame frame;
	private JPanel panel, arduinoPanel, dataPanel;
	private PortDropdownMenu portDropDown;
	private JButton startButton, stopButton, saveButton, connectButton, refreshButton, detectChannelsButton; 
	private Integer[] baudRates = {9600, 14400, 19200, 28800, 38400, 57600, 115200};
	private Integer[] dataChannels = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16};
	private JComboBox<Integer> baudRate, channelDropDown;
	private JCheckBox generateTimeChannelCheckbox;
	private JTextField fileNameField;
	private JLabel filePathField;
	private JLabel rawDataLabel, logDataLabel, logLabel, pillarInfoLabel;
	private JButton browseDirectoryButton;
	private File saveDir = new java.io.File(".");
	private JLabel messageLabel;
	private Arduino arduino;
	
	private boolean isConnected = false, isLogging = false;
	private TextLog textLog;
	
	public MangoLoggerGuiV2() {
		create();
	}
	
	private void create() {
		try {
			UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName());
		} catch(Exception ex) {
			ex.printStackTrace();
		}
		preferences = Preferences.userRoot().node(this.getClass().getName());
		
		frame = new JFrame("Mango Data Logger V2");
		frame.setSize(500, 500);
		panel = new JPanel();
		BoxLayout boxLayout = new BoxLayout(panel, BoxLayout.Y_AXIS);
		panel.setLayout(boxLayout);
		frame.add(panel);
		frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		
		JPanel recordPanel = new JPanel(new FlowLayout());
		JPanel saveDirPanel = new JPanel(new FlowLayout());
		JPanel saveFilePanel = new JPanel(new FlowLayout());
		JPanel columnSelectPanel = new JPanel(new FlowLayout());
		JPanel messagePanel = new JPanel(new FlowLayout());
		JPanel rawDataPanel = new JPanel(new FlowLayout());
		JPanel logDataPanel = new JPanel(new FlowLayout());
		JPanel pillarInfoPanel = new JPanel(new FlowLayout());
		arduinoPanel = new JPanel(new FlowLayout());
		int panelHeight = 30;
		arduinoPanel.setMaximumSize(new Dimension(frame.getWidth(), panelHeight));
		recordPanel.setMaximumSize(new Dimension(frame.getWidth(), panelHeight));
		
		saveFilePanel.setMaximumSize(new Dimension(frame.getWidth(), panelHeight));
		saveDirPanel.setMaximumSize(new Dimension(frame.getWidth(), panelHeight));
		columnSelectPanel.setMaximumSize(new Dimension(frame.getWidth(), panelHeight));
		messagePanel.setMaximumSize(new Dimension(frame.getWidth(), panelHeight));
		rawDataPanel.setMaximumSize(new Dimension(frame.getWidth(), panelHeight));
		logDataPanel.setMaximumSize(new Dimension(frame.getWidth(), panelHeight));
		pillarInfoPanel.setMaximumSize(new Dimension(frame.getWidth(), panelHeight));
		panel.add(arduinoPanel);
		panel.add(recordPanel);	
		panel.add(messagePanel);
		panel.add(saveDirPanel);
		panel.add(saveFilePanel);
		panel.add(columnSelectPanel);
		panel.add(rawDataPanel);
		panel.add(logDataPanel);
		panel.add(pillarInfoPanel);
		connectButton = new JButton("Connect to arduino");
		
		messageLabel = new JLabel();
		messagePanel.add(messageLabel);
		
		arduinoPanel.add(new JLabel("COM Port:"));
		portDropDown = new PortDropdownMenu();
		arduinoPanel.add(portDropDown);
		arduinoPanel.add(new JLabel("Baud Rate:"));
		baudRate = new JComboBox<Integer>(baudRates);
		arduinoPanel.add(baudRate);
		connectButton = new JButton("Connect");
		arduinoPanel.add(connectButton);
		portDropDown.setName("Port");
		portDropDown.refreshMenu();
		refreshButton = new JButton("Refresh");
		arduinoPanel.add(refreshButton);
		refreshButton.addActionListener(new ActionListener() {
			@Override
			public void actionPerformed(ActionEvent arg0) {
				portDropDown.refreshMenu();
			}
		});
		
		
		connectButton.addActionListener(new ActionListener() {			
			@Override
			public void actionPerformed(ActionEvent e) {
				
				if(!isConnected) {
					if(connect((String)portDropDown.getSelectedItem(), (int)baudRate.getSelectedItem())) {
						onConnect();
					}
				} else {
					if(arduino != null) arduino.closeConnection();
					onDisconnect();
				}
			}
		});
		
		startButton = new JButton("Start Log");
		stopButton = new JButton("Stop Logging");
		saveButton = new JButton("Save Log");
		recordPanel.add(startButton);
		recordPanel.add(stopButton);
		recordPanel.add(saveButton);
		startButton.setEnabled(false);
		stopButton.setEnabled(false);
		saveButton.setEnabled(false);
		
		startButton.addActionListener(new ActionListener() {		
			@Override
			public void actionPerformed(ActionEvent e) {
				startButton.setEnabled(false);
				stopButton.setEnabled(true);
				saveButton.setEnabled(true);
				connectButton.setEnabled(false);
				textLog = new TextLog();
				textLog.start();
				if(generateTimeChannelCheckbox.isSelected()) {
					textLog.add("Time\tx1\ty1\tx2\ty2");
				} else {
					textLog.add("x1\ty1\tx2\ty2");
				}
				isLogging = true;
			}
		});
		
		stopButton.addActionListener(new ActionListener() {		
			@Override
			public void actionPerformed(ActionEvent e) {
				startButton.setEnabled(true);
				stopButton.setEnabled(false);
				//saveButton.setEnabled(false);
				connectButton.setEnabled(true);
				if(isLogging) {
					isLogging = false;
				}
			}
		});
		
		saveButton.addActionListener(new ActionListener() {		
			@Override
			public void actionPerformed(ActionEvent e) {
				saveTextLog(textLog);
			}
		});
		
		saveDir = new File(preferences.get("OutputFilePath", saveDir.getAbsolutePath()));
		filePathField = new JLabel("Save Folder:" + saveDir.getAbsolutePath());
		saveDirPanel.add(filePathField);
		
		fileNameField = new JTextField("output_filename");
		fileNameField.setPreferredSize(new Dimension(200, fileNameField.getPreferredSize().height));
		JLabel saveAsLabel = new JLabel("Output filename:");
		browseDirectoryButton = new JButton("Change Folder");
		browseDirectoryButton.addActionListener(new ActionListener() {		
			@Override
			public void actionPerformed(ActionEvent e) {
				JFileChooser chooser = new JFileChooser();
				chooser.setCurrentDirectory(saveDir);
				chooser.setDialogTitle("Output file directory");
				chooser.setFileSelectionMode(JFileChooser.DIRECTORIES_ONLY);
				chooser.setAcceptAllFileFilterUsed(false);
				
				int returnVal = chooser.showOpenDialog(browseDirectoryButton);
				if (returnVal == JFileChooser.APPROVE_OPTION) {
					File file = chooser.getSelectedFile();
					//This is where a real application would open the file.
					saveDir = file;
					filePathField.setText("Save Folder:" + saveDir.getAbsolutePath());
					preferences.put("OutputFilePath", saveDir.getAbsolutePath());
					//setMessage("Save folder: " + saveDir.getAbsolutePath());
				} else {
					
				}
			}
		});
		
		saveFilePanel.add(saveAsLabel);
		saveFilePanel.add(fileNameField);
		saveFilePanel.add(browseDirectoryButton);
		
		columnSelectPanel.add(new JLabel("Channels:"));
		channelDropDown = new JComboBox<Integer>(dataChannels);
		columnSelectPanel.add(channelDropDown);
		detectChannelsButton = new JButton("Auto detect");
		detectChannelsButton.setEnabled(false);
		columnSelectPanel.add(detectChannelsButton);
		generateTimeChannelCheckbox = new JCheckBox("Add time channel");
		generateTimeChannelCheckbox.setSelected(true);
		columnSelectPanel.add(generateTimeChannelCheckbox);
		
		rawDataLabel = new JLabel("No input data");
		rawDataPanel.add(rawDataLabel);
		
		logLabel = new JLabel("No log started");
		logDataPanel.add(logLabel);
		
		pillarInfoLabel = new JLabel("No pillar data");
		pillarInfoPanel.add(pillarInfoLabel);
		
		frame.setVisible(true);
	}
	
	/** Attempt to connect to the specified port at specified baud rate
	 * @param port Port number, format "COMX" where X is integer
	 * @param baud Baud rate
	 * @return Success/failure of connection. Note that connection will succeed even if baud rate is incorrect, 
	 * or selected port does not contain a mango sensor.
	 */
	private boolean connect(String port, int baud) {
		arduino = new Arduino(port,baud);
		isConnected = arduino.openConnection();
		try {
			TimeUnit.MILLISECONDS.sleep(2000);
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
		SerialPort comPort = arduino.getSerialPort();
		comPort.addDataListener(new SerialPortDataListener() {
			ArrayList<Byte> inputBytes = new ArrayList<Byte>(); //incoming data line
			@Override
			public void serialEvent(SerialPortEvent event) {
				//check event type
				if (event.getEventType() != SerialPort.LISTENING_EVENT_DATA_AVAILABLE)
					return;
				byte[] newData = new byte[comPort.bytesAvailable()]; //make array for new data
				int numRead = comPort.readBytes(newData, newData.length); //get new data
				//add new data
				for(byte b:newData) {
					if((char)b == '\n') { 
						//if newline, process current sample, clear buffer for next one
						byte[] data = new byte[inputBytes.size()];
						for(int i=0; i<inputBytes.size(); i++) {
							data[i] = inputBytes.get(i);
						}
						MangoLoggerGuiV2.this.newInputLine(data);
						inputBytes = new ArrayList<Byte>();
					} else {
						inputBytes.add(b);
					}
				}
			}
			
			@Override
			public int getListeningEvents() {
				return SerialPort.LISTENING_EVENT_DATA_AVAILABLE;
			}
		});

		if(isConnected){
			setMessage("Connected to port " + port);
		} else {
			setMessage("Failed to connect");
		}
		return isConnected;
	}
	
	private void onConnect() {
		connectButton.setText("Disconnect");
		refreshButton.setEnabled(false);
		portDropDown.setEnabled(false);
		startButton.setEnabled(true);
		baudRate.setEnabled(false);
		detectChannelsButton.setEnabled(true);
		isConnected = true;
	}
	
	private void onDisconnect() {
		connectButton.setText("Connect");
		refreshButton.setEnabled(true);
		portDropDown.setEnabled(true);
		startButton.setEnabled(false);
		//stopButton.setEnabled(false);
		//saveButton.setEnabled(false);
		baudRate.setEnabled(true);
		detectChannelsButton.setEnabled(false);
		isConnected = false;
	}
	
	private void saveTextLog(TextLog log) {
		String filename = getNextFreeFileName(fileNameField.getText() + ".txt");
		boolean saveSuccess = textLog.save(saveDir.getAbsolutePath() + "/" + filename);
		setMessage("Saved output:" + filename);
	}
	
	private void setMessage(String text) {
		messageLabel.setText(text);
	}
	
	/** Triggers when a new line of data is input
	 * @param line
	 */
	private void newInputLine(byte[] bytes) {
		String inputLine = new String(bytes);
		MangoDataSample dataSample;
		String line = "";
		try {
			dataSample = new MangoDataSample(inputLine);
			if(!dataSample.isValid()) return;
			String pillarDataLine = "";
			for(int i=0; i<dataSample.getPillarCount(); i++) {
				MangoPillarSample pillarSample = dataSample.getPillarData(i);
				if(!line.equals("")) line += "\t";
				DecimalFormat f = new DecimalFormat("+#,##0.0000;-#");
				pillarDataLine += "  X:" + f.format(pillarSample.getX()) + "  Y:" + f.format(pillarSample.getY()) + "  Z:" + f.format(pillarSample.getZ());
			}
			pillarInfoLabel.setText(pillarDataLine); //display pillar data
			line = dataSample.generateLogLine();
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		
		String logLine = "";
		if(generateTimeChannelCheckbox.isSelected()) {
			if(textLog != null) {
				logLine = textLog.getTime() + "\t" + line;
			} else {
				logLine = "0" + "\t" + line;
			}
		} else {
			logLine = line;
		}
		if(isLogging) {
			textLog.add(logLine);
			logLabel.setText("Logging... Samples:" + textLog.getSampleCount());
		}
		rawDataLabel.setText(logLine.replaceAll("\t", " ")); //display raw data with tabs as spaces
	}
	
	public static void main(String[] args) {
		MangoLoggerGuiV2 mangoLoggerGui = new MangoLoggerGuiV2();
	}
	
	public String getNextFreeFileName(String baseFileName) {
		File testFile = new File(saveDir, baseFileName);
		if(!testFile.exists()) return baseFileName;
		int counter = 1;
	  	while(true) {
	  		System.out.println(counter);
	  		String fileName = baseFileName + "(" + counter + ")";
	  		testFile = new File(saveDir, fileName);
	  		if(!testFile.exists()) return fileName;
	  		counter++;
	  	}
	}
}
