import React, { Component } from "react";
import { requireNativeComponent, Dimensions } from "react-native";

const DamageCameraView = requireNativeComponent("DamageCameraView");

export default class DamageCamera extends Component {
  constructor(props) {
    super(props);
    this.state = {
      width: Dimensions.get("window").width,
      height: Dimensions.get("window").height
    };

    this.onLayout = this.onLayout.bind(this);
  }
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
    if (!this.props.onDamageReported) {
      return;
    }
    this.props.onDownloadProgress(event.nativeEvent);
  };

  _onDownloadComplete = event => {
    if (!this.props.onDamageReported) {
      return;
    }
    this.props.onDownloadComplete(event.nativeEvent);
  };

  _onError = event => {
    if (!this.props.onDamageReported) {
      return;
    }
    this.props.onError(event.nativeEvent);
  };

  onLayout(e) {
    this.setState({
      width: Dimensions.get("window").width,
      height: Dimensions.get("window").height
    });
  }

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
        onLayout={this.onLayout}
        style={{ width: this.state.width }}
        {...nativeProps}
      />
    );
  }
}
