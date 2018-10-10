import React, { Component } from "react";
import { requireNativeComponent } from "react-native";

const DamageCameraView = requireNativeComponent("DamageCameraView");

export default class DamageCamera extends Component {
  _onDamageDetected = event => {
    if (!this.props.onDamageDetected) {
      return;
    }
    this.props.onDamageDetected(event.nativeEvent);
  };

  render() {
    const nativeProps = {
      ...this.props,
      onDamageDetected: this._onDamageDetected
    };
    return <DamageCameraView {...nativeProps} />;
  }
}
