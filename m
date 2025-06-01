import javafx.animation.TranslateTransition;
import javafx.beans.binding.Bindings;
import javafx.geometry.Insets;
import javafx.scene.Node;
import javafx.scene.Scene;
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

        // Užtikrinam, kad content užims visą plotą kai startuoja
        updateContentWidth();

        // Klausomės pločio pokyčių kad automatiškai perskaičiuotų
        mainArea.widthProperty().addListener((obs, oldVal, newVal) -> updateContentWidth());
    }

    public void openPage(Page page) {
        Pane pageView;
        if (page.isTaskList()) {
            pageView = new TaskListPage(page, this).getView();
        } else {
            pageView = new NotePage(page, this).getView();
        }
        mainArea.getChildren().set(1, pageView);

        // Po puslapio atidarymo atnaujiname content pločio bindingą
        updateContentWidth();
    }

    public void toggleSidebar() {
        boolean showing = sidebar.getView().isVisible();

        if (showing) {
            TranslateTransition slideOut = new TranslateTransition(Duration.millis(200), sidebar.getView());
            slideOut.setToX(-sidebar.getView().getWidth());
            slideOut.setOnFinished(e -> {
                sidebar.getView().setVisible(false);
                sidebar.getView().setManaged(false);
                sidebar.getView().setTranslateX(0); // reset translate X
                updateContentWidth();
            });
            slideOut.play();
        } else {
            sidebar.getView().setManaged(true);
            sidebar.getView().setVisible(true);
            sidebar.getView().setTranslateX(-sidebar.getView().getWidth());

            TranslateTransition slideIn = new TranslateTransition(Duration.millis(200), sidebar.getView());
            slideIn.setToX(0);
            slideIn.setOnFinished(e -> updateContentWidth());
            slideIn.play();
        }
    }

  private void updateContentWidth() {
    Region sidebarView = (Region) sidebar.getView();
    Region content = (Region) mainArea.getChildren().get(1);

    if (sidebarView.isVisible() && sidebarView.isManaged()) {
        content.prefWidthProperty().unbind();
        content.prefWidthProperty().bind(Bindings.createDoubleBinding(() ->
            mainArea.getWidth() - sidebarView.getBoundsInParent().getWidth(),
            mainArea.widthProperty(), sidebarView.boundsInParentProperty()));
    } else {
        content.prefWidthProperty().unbind();
        content.prefWidthProperty().bind(mainArea.widthProperty());
    }
}


    public boolean isSidebarVisible() {
        return sidebar.getView().isVisible();
    }

    public Sidebar getSidebar() {
        return sidebar;
    }
}
