import java.awt.*;
import java.awt.event.*;
import java.nio.channels.FileChannel;
import java.io.FileInputStream;
import java.io.FileOutputStream;

Label label_cv_ver;
TextField field_location;
TextField field_project_name;
TextField field_project_location;
Checkbox chk_vs2012;
Checkbox chk_vs2013;
Button bt_browse;
Button bt_browse2;
Button bt_generate;

ArrayList<OpenCVInfo> cv_list = new ArrayList<OpenCVInfo>();
String user_vc_ver;
String user_opencv_ver;
String user_opencv_dir;
String user_project_dir;
String user_project_name;
String base_file_dir;


void setup() {  
  size(900, 360);  
  frame.setTitle("OpenCV Project Generator for Windows");
  createUI(dataPath("opencv_list.txt"), dataPath("default_config.txt"));
}


String getOpenCVVersion(String opencv_dir) {
  String dir = removeLastYen(opencv_dir);
  for ( OpenCVInfo info : cv_list ) {
    if ( file_exists( dir + info.key_file ) ) {
      return info.version_label;
    }
  }
  return null;
}


void draw() {
  background(221);

  // vc version
  if ( chk_vs2012.getState() ) { 
    user_vc_ver = "vc11";
  }
  if ( chk_vs2013.getState() ) { 
    user_vc_ver = "vc12";
  }

  // opencv location  
  user_opencv_dir = field_location.getText();

  // save dir
  user_project_dir = field_project_location.getText();

  // project name
  user_project_name = field_project_name.getText();

  // opencv version check
  String cv_ver = getOpenCVVersion(user_opencv_dir);
  if ( cv_ver == null ) {
    label_cv_ver.setText("OpenCV is not found in this directory.");
    label_cv_ver.setForeground(Color.red);
  } else {
    label_cv_ver.setText("Version " + cv_ver + " is detected.");
    label_cv_ver.setForeground(Color.blue);
    for (OpenCVInfo info : cv_list ) {
      if ( info.version_label.equals(cv_ver) ) {
        user_opencv_ver = info.version_number;
        base_file_dir   = info.base_file_dir;
      }
    }
  }

  /*
  println("------------");
   println(user_vc_ver);
   println(user_opencv_ver);
   println(user_opencv_dir);
   println(user_project_name);
   println(user_project_dir);
   println(base_file_dir);
   */
}



void saveProcess(String src_dir, String dst_dir, String project_name, String opencv_install_path, String opencv_ver, String vc_ver) {
  /*  
   // example
   String src_dir = "for_opencv_2.4.x";  // base file
   String dst_dir = "C:\\Users\\hashimoto\\Desktop";
   String project_name = "TestProject";
   String opencv_install_path = "C:\\opencv";
   String opencv_ver = "249";
   String vc_ver = "vc11";
   */

  src_dir = removeLastYen(src_dir);
  dst_dir = removeLastYen(dst_dir);

  // base file (relative path, in "data" folder)
  String src_solution_path = src_dir + "\\OpenCVSolution.sln";
  String src_project_path  = src_dir + "\\OpenCVProject.vcxproj";
  String src_filter_path   = src_dir + "\\OpenCVProject.vcxproj.filters";

  String dst_solution_path = dst_dir + "\\" + project_name + "\\" + project_name + ".sln";
  String dst_project_path  = dst_dir + "\\" + project_name + "\\" + project_name + ".vcxproj";
  String dst_filter_path   = dst_dir + "\\" + project_name + "\\" + project_name + ".vcxproj.filters";

  createSolutionFile( src_solution_path, dst_solution_path, project_name, project_name, vc_ver );
  createProjectFile( src_project_path, dst_project_path, project_name, opencv_install_path, opencv_ver, vc_ver );
  try {
    copyFile( src_filter_path, dst_filter_path );
  } 
  catch (IOException e) {
    e.printStackTrace();
  }

  //----------------

  File src_file = new File(src_dir);
  File src_files[] = src_file.listFiles();  

  for ( File file : src_files ) {
    String src_file_path = file.getAbsolutePath();    
    String dst_file_path = dst_dir + "\\" + project_name + "\\" + file.getName();
    if ( !src_file_path.equals(src_solution_path) && 
      !src_file_path.equals(src_project_path) &&
      !src_file_path.equals(src_filter_path) ) {
      try {
        copyFile( src_file_path, dst_file_path );
      } 
      catch (IOException e) {
        e.printStackTrace();
      }
    }
  }
}



void copyFile(String srcPath, String destPath) throws IOException {
  FileChannel srcChannel = new FileInputStream(srcPath).getChannel();
  FileChannel destChannel = new FileOutputStream(destPath).getChannel();
  try {
    srcChannel.transferTo(0, srcChannel.size(), destChannel);
  } 
  finally {
    srcChannel.close();
    destChannel.close();
  }
}


void createSolutionFile(String src, String dst, String solution_name, String project_name, String vc_ver) {
  String[] buf = loadStrings(src);

  for (int i=0; i<buf.length; i++) {
    buf[i] = buf[i].replace( "OpenCVSolution", solution_name );
    buf[i] = buf[i].replace( "OpenCVProject.vcxproj", project_name + ".vcxproj");
    if ( vc_ver.equals("vc12") ) {
      buf[i] = buf[i].replace( "Visual Studio Express 2012", "Visual Studio Express 2013");
    }
  }

  PrintWriter writer = createWriter(dst); 
  for (String line : buf) {
    writer.println(line);
  }
  writer.flush();
  writer.close();
}


void createProjectFile(String src, String dst, String project_name, String opencv_install_path, String opencv_ver, String vc_ver) {
  String[] buf = loadStrings(src);

  String platform = "????";
  if ( vc_ver.equals("vc11") ) { 
    platform = "v110";
  }
  if ( vc_ver.equals("vc12") ) { 
    platform = "v120";
  }

  for (int i=0; i<buf.length; i++) {
    buf[i] = buf[i].replace( "[VC_VERSION]", platform );
    buf[i] = buf[i].replace( "[OPENCV_INCLUDE]", opencv_install_path + "\\build\\include;" );    
    buf[i] = buf[i].replace( "[OPENCV_LIB_X86]", opencv_install_path + "\\build\\x86\\" + vc_ver + "\\lib;" );
    buf[i] = buf[i].replace( "[OPENCV_LIB_X64]", opencv_install_path + "\\build\\x64\\" + vc_ver + "\\lib;" );
    buf[i] = buf[i].replace( "[OPENCV_BIN_X86]", opencv_install_path + "\\build\\x86\\" + vc_ver + "\\bin" );
    buf[i] = buf[i].replace( "[OPENCV_BIN_X64]", opencv_install_path + "\\build\\x64\\" + vc_ver + "\\bin" );
  }

  PrintWriter writer = createWriter(dst); 
  for (String line : buf) {
    writer.println(line);
  }
  writer.flush();
  writer.close();
}


void createUI( String opencv_list_file, String default_config_file ) {

  //-----------------------------------------------------------------------------
  // load opencv_list.txt 
  String [] lines = loadStrings(opencv_list_file);
  for (int i=0; i < lines.length; i++) {
    String[] data = split( trim(lines[i]), '\t' );
    if ( data.length == 4 ) {
      cv_list.add ( new OpenCVInfo(data[0], data[1], dataPath(data[2]), data[3]) );
    }
  }

  //-----------------------------------------------------------------------------
  // load default_config.txt 
  String[] temp = loadStrings(default_config_file);  
  String default_opencv_location  = temp[0];
  String default_project_name     = temp[1];
  String default_project_location = temp[2];

  if ( default_project_location.equals("Desktop") ) {
    default_project_location = getDesktopPath();
  } else if ( default_project_location.equals("Document") ) {
    default_project_location = getDocumentPath();
  }

  setLayout(null);

  //-----------------------------------------------------------------------------
  Label label_vs = new Label("Visual Studio");
  label_vs.setFont( new Font("DIALOG", Font.PLAIN, 20) );
  label_vs.setBounds( 20, 10, 120, 30 );
  add(label_vs);

  CheckboxGroup g = new CheckboxGroup();  
  chk_vs2012 = new Checkbox("2012", false, g);
  chk_vs2012.setFont( new Font("DIALOG", Font.PLAIN, 20) );
  chk_vs2012.setBounds( 20, 70, 100, 30 );  
  add(chk_vs2012);

  chk_vs2013 = new Checkbox("2013", true, g);
  chk_vs2013.setFont( new Font("DIALOG", Font.PLAIN, 20) );    
  chk_vs2013.setBounds( 20, 40, 100, 30 );
  add(chk_vs2013);

  //-----------------------------------------------------------------------------
  Label label_dir = new Label("OpenCV Location");
  label_dir.setFont( new Font("DIALOG", Font.PLAIN, 20) );
  label_dir.setBounds( 210, 15, 170, 30 );
  add(label_dir);

  field_location = new TextField(default_opencv_location);
  field_location.setFont( new Font("DIALOG", Font.PLAIN, 23) );
  field_location.setBounds( 210, 48, 560, 30 );
  add(field_location);

  bt_browse = new Button("Browse");
  bt_browse.setFont( new Font("DIALOG", Font.PLAIN, 20) );
  bt_browse.setBounds( 780, 48, 100, 30 );
  bt_browse.setBackground(new Color(120, 202, 242));
  bt_browse.addActionListener(new BrowseButtonActionListener());
  add(bt_browse);

  label_cv_ver = new Label("library searching...");
  label_cv_ver.setFont( new Font("DIALOG", Font.PLAIN, 20) );
  label_cv_ver.setBounds( 380, 15, 400, 30 );
  add(label_cv_ver);

  //-----------------------------------------------------------------------------
  Label label_project = new Label("New Project Name");
  label_project.setFont( new Font("DIALOG", Font.PLAIN, 20) );
  label_project.setBounds( 210, 105, 170, 30 );
  add(label_project);

  field_project_name = new TextField(default_project_name);
  field_project_name.setFont( new Font("DIALOG", Font.PLAIN, 23) );
  field_project_name.setBounds( 210, 135, 470, 30 );
  add(field_project_name);

  bt_browse2 = new Button("Browse");
  bt_browse2.setFont( new Font("DIALOG", Font.PLAIN, 20) );
  bt_browse2.setBounds( 680, 218, 100, 30 );
  bt_browse2.addActionListener(new BrowseButtonActionListener2());
  add(bt_browse2);

  //-----------------------------------------------------------------------------
  Label label_projloc = new Label("Save to");
  label_projloc.setFont( new Font("DIALOG", Font.PLAIN, 20) );
  label_projloc.setBounds( 210, 185, 170, 30 );
  add(label_projloc);

  field_project_location = new TextField(default_project_location);
  field_project_location.setFont( new Font("DIALOG", Font.PLAIN, 23) );
  field_project_location.setBounds( 210, 218, 460, 30 );
  add(field_project_location);

  bt_generate = new Button("Generate Project");
  bt_generate.setFont( new Font("DIALOG", Font.PLAIN, 30) );
  bt_generate.setBounds( 580, 280, 300, 50 );
  bt_generate.setBackground(new Color(255, 223, 41));
  bt_generate.addActionListener(new GenerateButtonActionListener());
  add(bt_generate);

  //-----------------------------------------------------------------------------
  Label label_available = new Label("Available versions");
  label_available.setFont( new Font("DIALOG", Font.PLAIN, 20) );
  label_available.setBounds( 20, 150, 180, 30 );
  add(label_available);

  for (int i=0; i<cv_list.size (); i++) {
    OpenCVInfo info = cv_list.get(i);
    Label label = new Label("ver." + info.version_label);
    label.setFont( new Font("DIALOG", Font.PLAIN, 18) );
    label.setBounds( 20, 180+i*25, 170, 25 );
    add(label);
  }
}

class GenerateButtonActionListener implements ActionListener {
  public void actionPerformed(ActionEvent e) {
    saveProcess( base_file_dir, user_project_dir, user_project_name, user_opencv_dir, user_opencv_ver, user_vc_ver );
  }
}

void saveFileSelected(File selection) {
  if (selection != null) {
    println("User selected " + selection.getAbsolutePath());
  }
}

class BrowseButtonActionListener implements ActionListener {
  public void actionPerformed(ActionEvent e) {
    selectFolder("Select the opencv loation:", "folderSelected");
  }
}

class BrowseButtonActionListener2 implements ActionListener {
  public void actionPerformed(ActionEvent e) {
    selectFolder("Select a save directory", "folderSelected2");
  }
}

void folderSelected(File selection) {
  if (selection != null) {
    field_location.setText( selection.getAbsolutePath() );
  }
}

void folderSelected2(File selection) {
  if (selection != null) {
    field_project_location.setText( selection.getAbsolutePath() );
  }
}

