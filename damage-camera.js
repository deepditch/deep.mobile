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

  _onDamageReported = event => {
    if (!this.props.onDamageReported) {
      return;
    }
    this.props.onDamageReported(event.nativeEvent);
  };

  render() {
    const nativeProps = {
      ...this.props,
      onDamageDetected: this._onDamageDetected,
      onDamageReported: this._onDamageReported
    };
    return <DamageCameraView {...nativeProps} />;
  }
}
