import javafx.animation.TranslateTransition;
import javafx.beans.binding.Bindings;
import javafx.geometry.Insets;
import javafx.geometry.Pos;
import javafx.scene.Scene;
import javafx.scene.control.Button;
import javafx.scene.image.Image;
import javafx.scene.layout.*;
import javafx.stage.Stage;
import javafx.stage.StageStyle;
import javafx.util.Duration;

import java.io.File;

public class Window {
    private BorderPane root;
    private Sidebar sidebar;
    private TopBar topBar;
    private HBox mainArea;
    private StackPane centerOverlay;

    public Window() { }

    public void show(Stage stage) {
        topBar = new TopBar(stage);
        stage.setUserData(this);
        root = new BorderPane();
        root.setTop(topBar.getView());

        sidebar = new Sidebar(this);

        Pane initial = new NotePage(PageStorageManager.getHomePage(), this).getView();

        mainArea = new HBox(sidebar.getView(), initial);
        HBox.setHgrow(initial, Priority.ALWAYS);

        centerOverlay = new StackPane(mainArea);
        root.setCenter(centerOverlay);

        sidebar.getView().setTranslateX(0);
        mainArea.getChildren().get(1).setTranslateX(0);

        Scene scene = new Scene(root, 1080, 720);
        String cssUri = new File("Styles.css").toURI().toString();
        scene.getStylesheets().add(cssUri);

        stage.initStyle(StageStyle.UNDECORATED);
        stage.setScene(scene);
        stage.setTitle("TimeBuddy");
        String iconUri = new File("Logo.png").toURI().toString();
        stage.getIcons().add(new Image(iconUri));

        stage.show();
        stage.centerOnScreen();
    }

    public void openPage(Page page) {
        Pane pageView;
        if (page.isTaskList()) {
            pageView = new TaskListPage(page, this).getView();
        } else {
            pageView = new NotePage(page, this).getView();
        }
        mainArea.getChildren().set(1, pageView);
    }

    // public void toggleSidebar() {
    //     boolean showing = sidebar.isVisible();
    //     TranslateTransition slide = new TranslateTransition(Duration.millis(200), sidebar.getView());
    //     slide.setToX(showing ? -300 : 0);
    //     slide.play();

    //     sidebar.getView().setVisible(!showing);
    // }

    public void toggleSidebar() {
    boolean showing = sidebar.isVisible();
    if (showing) {
        mainArea.getChildren().remove(sidebar.getView());
    } else {
        mainArea.getChildren().add(0, sidebar.getView());
    }

    sidebar.getView().setVisible(!showing);
}


    public boolean isSidebarVisible() {
        return sidebar.isVisible();
    }

    public Sidebar getSidebar() {
    return sidebar;
}

}
