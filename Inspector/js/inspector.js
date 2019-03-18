/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

import PropTypes from 'prop-types';
import React from 'react';

import HTTP from 'js/http';
var Button = require('react-button');

require('css/inspector.css');

function boolToString(boolValue) {
  return boolValue === '1' ? 'Yes' : 'No';
}

class Inspector extends React.Component {
  render() {
    return (
      <div id="inspector" className="section third">
        <div className="section-caption">
          Inspector
        </div>
        <div className="section-content-container">
          <div className="section-content" style={{overflowY:'scoll'}}>
            {this.renderInspector()}
          </div>
          <div className="section-content" style={{height:'40%'}}>
            <div> Test Script </div>
            <textarea className="inspector-script-text">
            </textarea>
          </div>
        </div>
      </div>
    );
  }

  renderInspector() {
    if (this.props.selectedNode == null) {
      return null;
    }

    const attributes = this.props.selectedNode.attributes;
    const tapButton =
      <Button onClick={(event) => this.tap(this.props.selectedNode)}>
        tap
      </Button>;

    return (
      <div>
        {this.renderField('Class', attributes.type)}
        {this.renderField('Path', attributes.classChain)}
        {this.renderField('Rect', attributes.rect)}
        {this.renderField('isEnabled', boolToString(attributes.isEnabled))}
        {this.renderField('Tap', tapButton, false)}
     </div>
    );
  }

  renderField(fieldName, fieldValue, castToString = true) {
    if (fieldValue == null) {
      return null;
    }
    var value;
    if (castToString) {
      value = String(fieldValue);
    } else {
      value = fieldValue;
    }
    return (
      <div className="inspector-field">
        <span className="inspector-field-caption">
          {fieldName}:
        </span>
        <span className="inspector-field-value">
          {value}
        </span>
      </div>
    );
  }

  tap(node) {
    HTTP.get(
      'status', (status_result) => {
        var session_id = status_result.sessionId;
        HTTP.post(
          'session/' + session_id + '/elements',
          JSON.stringify({
            'using': 'class chain',
            'value': node.attributes.classChain,
          }),
          (elements_result) => {
            var elements = elements_result.value;
            var element_id = elements[0].ELEMENT;

            HTTP.post(
              'session/' + session_id + '/element/' + element_id + '/click',
              JSON.stringify({}),
              (result) => {
                setTimeout(function () {
                  this.props.refreshApp();
                }.bind(this), 1000)
              },
            );
          },
        );
      },
    );
  }
}

Inspector.propTypes = {
  selectedNode: PropTypes.object,
};

module.exports = Inspector;
