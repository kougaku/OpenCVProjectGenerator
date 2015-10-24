import java.awt.*;
import java.awt.event.*;
import java.nio.channels.FileChannel;
import java.io.FileInputStream;
import java.io.FileOutputStream;


String removeLastYen(String path) {
  while ( path.charAt (path.length ()-1) == '\\' ) {
    if ( path.charAt(path.length()-2) == ':' ) break;
    path = path.substring(0, path.length()-1);
  }
  return path;
}

String getDesktopPath() {
  File file = new File(System.getProperty("user.home"), "Desktop");
  return file.getAbsolutePath();
}

String getDocumentPath() {
  File file = new File(System.getProperty("user.home"), "Document");
  return file.getAbsolutePath();
}

String getFileNameFromPath(String path) {
  File f = new File( path );
  return f.getName();
}

boolean file_exists( String file_path ) {
  File f = new File( file_path );
  return f.exists();
}

