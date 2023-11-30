package com.bundleupdater;

import android.content.Context;
import android.graphics.Color;
import android.graphics.drawable.GradientDrawable;
import android.view.View;
import android.widget.Button;
import android.widget.LinearLayout;

public class BundleUpdaterButton  {

  private LinearLayout layout;
  private Button button;
  private View layer1;

  public BundleUpdaterButton(Context context) {
    layout = new LinearLayout(context);
    button = new Button(context);
    layout.addView(button);
    LinearLayout shadows = new LinearLayout(context);
    shadows.setLayoutParams(
      new LinearLayout.LayoutParams(
        LinearLayout.LayoutParams.MATCH_PARENT,
        LinearLayout.LayoutParams.MATCH_PARENT
      )
    );
    shadows.setClipChildren(false);
    shadows.setClipToPadding(false);
    layout.addView(shadows);

    GradientDrawable shape = new GradientDrawable();
    shape.setCornerRadius(16);
    shape.setColor(Color.parseColor("#007AFF"));

    layer1 = new View(context);
    layer1.setBackground(shape);
    layer1.setLayoutParams(
      new LinearLayout.LayoutParams(
        LinearLayout.LayoutParams.MATCH_PARENT,
        LinearLayout.LayoutParams.MATCH_PARENT
      )
    );
    shadows.addView(layer1);

    GradientDrawable gradient = new GradientDrawable(
      GradientDrawable.Orientation.LEFT_RIGHT,
      new int[] { Color.WHITE, Color.TRANSPARENT }
    );
    gradient.setGradientType(GradientDrawable.LINEAR_GRADIENT);
    gradient.setGradientCenter(0.25f, 0.5f);
    gradient.setGradientRadius(6);
    gradient.setGradientType(GradientDrawable.RADIAL_GRADIENT);
    gradient.setGradientRadius(1);
    gradient.setGradientCenter(1, 0);
    gradient.setShape(GradientDrawable.RECTANGLE);
    gradient.setCornerRadius(16);
    gradient.setStroke(1, Color.parseColor("#F2F2F2"));

    View shapes = new View(context);
    shapes.setLayoutParams(
      new LinearLayout.LayoutParams(
        LinearLayout.LayoutParams.MATCH_PARENT,
        LinearLayout.LayoutParams.MATCH_PARENT
      )
    );
    //shapes.setClipChildren(true);
    //shapes.setClipToPadding(true);
    shapes.setBackground(gradient);
    layout.addView(shapes);
  }

  public void setButtonColor(int color) {
    layer1.setBackgroundColor(color);
  }

  public View getView() {
    return layout;
  }
}
