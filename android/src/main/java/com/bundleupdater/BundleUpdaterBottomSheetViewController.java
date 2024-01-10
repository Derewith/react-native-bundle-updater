package com.bundleupdater;

import android.content.Context;
import android.graphics.Color;
import android.graphics.PixelFormat;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

public class ListItem {

  public String title;
  public String message;
  public String imageUrl;
  public String buttonText;

  public ListItem(
    String title,
    String message,
    String imageUrl,
    String buttonText
  ) {
    this.title = title;
    this.message = message;
    this.imageUrl = imageUrl;
    this.buttonText = buttonText;
  }
}

public class BundleUpdaterBottomSheetViewController {

  private ImageView imageView;
  private TextView titleLabel;
  private TextView messageLabel;
  private Button button;
  private ImageView footerLogoImageView;
  private View backgroundView;
  private LinearLayout modalView;
  private Context context;
  private WindowManager windowManager;

  public BundleUpdaterBottomSheetViewController(Context context) {
    this.context = context;
    this.windowManager =
      (WindowManager) context.getSystemService(Context.WINDOW_SERVICE);
  }

  public void show() {
    Handler mainHandler = new Handler(context.getMainLooper());
    mainHandler.post(() -> {
      // Your existing code to show the view
      // Initialize views
      imageView = new ImageView(context);
      titleLabel = new TextView(context);
      messageLabel = new TextView(context);
      button = new Button(context);
      footerLogoImageView = new ImageView(context);
      backgroundView = new View(context);
      modalView = new LinearLayout(context);

      // Set properties for views
      imageView.setLayoutParams(new ViewGroup.LayoutParams(60, 60));
      titleLabel.setLayoutParams(
        new ViewGroup.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, 30)
      );
      messageLabel.setLayoutParams(
        new ViewGroup.LayoutParams(
          ViewGroup.LayoutParams.WRAP_CONTENT,
          ViewGroup.LayoutParams.WRAP_CONTENT
        )
      );
      button.setLayoutParams(new ViewGroup.LayoutParams(184, 46));
      footerLogoImageView.setLayoutParams(new ViewGroup.LayoutParams(172, 24));

      // Set background color for modal view
      modalView.setBackgroundColor(Color.WHITE);
      modalView.setPadding(20, 20, 20, 20);
      modalView.setOrientation(LinearLayout.VERTICAL);

      // Add views to modal view
      modalView.addView(imageView);
      modalView.addView(titleLabel);
      modalView.addView(messageLabel);
      modalView.addView(button);
      modalView.addView(footerLogoImageView);

      WindowManager.LayoutParams params = new WindowManager.LayoutParams(
        WindowManager.LayoutParams.MATCH_PARENT,
        WindowManager.LayoutParams.MATCH_PARENT,
        WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
        WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
        PixelFormat.TRANSLUCENT
      );
      params.gravity = Gravity.BOTTOM | Gravity.CENTER_HORIZONTAL;
      params.dimAmount = 1f;

      windowManager.addView(modalView, params);
    });
  }

  public void dismiss() {
    if (modalView != null) {
      windowManager.removeView(modalView);
      modalView = null;
    }
  }

  public void visitWebsiteButtonTapped() {
    String url = "https://www.develondigital.com";
    Uri uri = Uri.parse(url);
    // Open the website in a browser
  }

  public void reloadApp() {
    // Reload the app
  }

  public void updateViewConstraints() {
    // Update view constraints here
  }

  public void viewDidAppear() {
    // Show the modal view with animation
    backgroundView.setAlpha(0.5f);
  }
}
