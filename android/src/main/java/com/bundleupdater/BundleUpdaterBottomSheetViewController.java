package com.bundleupdater;

import android.content.Context;
import android.graphics.Color;
import android.net.Uri;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

public class BundleUpdaterBottomSheetViewController {

  private ImageView imageView;
  private TextView titleLabel;
  private TextView messageLabel;
  private Button button;
  private ImageView footerLogoImageView;
  private View backgroundView;
  private LinearLayout modalView;

  public void viewDidLoad(Context context) {
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
