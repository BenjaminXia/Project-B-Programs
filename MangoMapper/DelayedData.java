import java.util.ArrayList;

class DelayedData {
  private int delay; //ms
  private ArrayList<Entry> array = new ArrayList<Entry>();
  
  DelayedData(int ms) {
    delay = ms; 
  }
  
  public void add(String data, int t) {
    //println("add:" + x + "," + y);
    array.add(new Entry(data, t)); //println("Added, size =" + array.size());
  }
  
  public String get(int curTime) {
    if(array.size() == 0) return null;
    Entry entry = null;
    while(curTime - array.get(0).time > delay) {
      entry = array.remove(0);
      //println("Added, size =" + array.size());
    }
    if(entry == null){
      return null;
    } 
    //println(curTime + "," + entry.time + "\t" + entry.data.x + "," + entry.data.y);
    return entry.data;
  }
  
  private class Entry{
    String data;
    int time;
    Entry(String data, int t) {
       this.data = data;
       time = t;
    }
  }
}