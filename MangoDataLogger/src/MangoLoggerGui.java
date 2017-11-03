import java.awt.BorderLayout;
import java.awt.Dimension;
import java.awt.FlowLayout;
import java.awt.GridLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.File;
import java.util.concurrent.TimeUnit;

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

public class MangoLoggerGui {
	private JFrame frame;
	private JPanel panel, arduinoPanel, dataPanel;
	private PortDropdownMenu portDropDown;
	private JButton startButton, stopButton, saveButton, connectButton, refreshButton, detectChannelsButton; 
	private Integer[] baudRates = {9600, 14400, 19200, 28800, 38400, 57600, 115200};
	private Integer[] dataChannels = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16};
	private JComboBox<Integer> baudRate, channelDropDown;
	private JCheckBox generateTimeChannelCheckbox;
	private JTextField fileNameField;
	private JLabel rawDataLabel, logLabel;
	private JButton browseDirectoryButton;
	private File saveDir = new java.io.File(".");
	private JLabel messageLabel;
	private Arduino arduino;
	
	private boolean isConnected = false, isLogging = false;
	private TextLog textLog;
	
	public MangoLoggerGui() {
		create();
	}
	
	private void create() {
		try {
			UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName());
		} catch(Exception ex) {
			ex.printStackTrace();
		}
		frame = new JFrame("Mango Data Logger");
		frame.setSize(500, 500);
		panel = new JPanel();
		BoxLayout boxLayout = new BoxLayout(panel, BoxLayout.Y_AXIS);
		panel.setLayout(boxLayout);
		frame.add(panel);
		frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		
		JPanel recordPanel = new JPanel(new FlowLayout());
		JPanel saveFilePanel = new JPanel(new FlowLayout());
		JPanel columnSelectPanel = new JPanel(new FlowLayout());
		JPanel messagePanel = new JPanel(new FlowLayout());
		JPanel rawDataPanel = new JPanel(new FlowLayout());
		JPanel logDataPanel = new JPanel(new FlowLayout());
		arduinoPanel = new JPanel(new FlowLayout());
		int panelHeight = 30;
		arduinoPanel.setMaximumSize(new Dimension(frame.getWidth(), panelHeight));
		recordPanel.setMaximumSize(new Dimension(frame.getWidth(), panelHeight));
		saveFilePanel.setMaximumSize(new Dimension(frame.getWidth(), panelHeight));
		columnSelectPanel.setMaximumSize(new Dimension(frame.getWidth(), panelHeight));
		messagePanel.setMaximumSize(new Dimension(frame.getWidth(), panelHeight));
		rawDataPanel.setMaximumSize(new Dimension(frame.getWidth(), panelHeight));
		panel.add(arduinoPanel);
		panel.add(recordPanel);	
		panel.add(messagePanel);
		panel.add(saveFilePanel);
		panel.add(columnSelectPanel);
		panel.add(rawDataPanel);
		panel.add(logDataPanel);
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
					setMessage("Save folder: " + saveDir.getAbsolutePath());
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
		
		frame.setVisible(true);
	}
	
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
			String currentLine = "";
			@Override
			public void serialEvent(SerialPortEvent event) {
				// TODO Auto-generated method stub
				if (event.getEventType() != SerialPort.LISTENING_EVENT_DATA_AVAILABLE)
					return;
				byte[] newData = new byte[comPort.bytesAvailable()];
				int numRead = comPort.readBytes(newData, newData.length);
				for(byte b:newData) {
					char c = (char)b;
					if(c == '\n') {
						MangoLoggerGui.this.newInputLine(currentLine);
						currentLine = "";
					} else {
						currentLine += c;
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
	
	private void newInputLine(String line) {
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
		MangoLoggerGui mangoLoggerGui = new MangoLoggerGui();
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
