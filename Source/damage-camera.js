import React, { Component } from "react";
import { requireNativeComponent, Dimensions } from "react-native";

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

  _onDownloadProgress = event => {
    console.log("Camera: ", event.nativeEvent.progress)
    if (!this.props.onDownloadProgress) {
      return;
    }
    this.props.onDownloadProgress(event.nativeEvent);
  };

  _onDownloadComplete = event => {
    if (!this.props.onDownloadComplete) {
      return;
    }
    this.props.onDownloadComplete(event.nativeEvent);
  };

  _onError = event => {
    if (!this.props.onError) {
      return;
    }
    this.props.onError(event.nativeEvent);
  };

  render() {
    const nativeProps = {
      ...this.props,
      onDamageDetected: this._onDamageDetected,
      onDamageReported: this._onDamageReported,
      onDownloadProgress: this._onDownloadProgress,
      onDownloadComplete: this._onDownloadComplete,
      onError: this._onError
    };
    return (
      <DamageCameraView
        {...nativeProps}
      />
    );
  }
}
