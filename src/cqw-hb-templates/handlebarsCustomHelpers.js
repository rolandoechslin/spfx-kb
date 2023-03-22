ReactContentQuery.ExternalScripts.handlebarsCustomHelpers = {
    onPreRender: function (wpContext, handlebarsContext) {
      // 
      handlebarsContext.registerHelper("ifEquals", function (a, b, options) {
        if (a === b) {
          return options.fn(this);
        } else {
          return options.inverse(this);
        }
      });
  
      // 
      handlebarsContext.registerHelper("join", function (array, separator) {
        return array.join(separator);
      });
  
      // <pre></pre>
      handlebarsContext.registerHelper("json", function (obj) {
        return JSON.stringify(obj);
      });
  
      handlebarsContext.registerHelper(
        "math",
        function (lvalue, operator, rvalue) {
          lvalue = parseFloat(lvalue);
          rvalue = parseFloat(rvalue);
  
          switch (operator) {
            case "+":
              return lvalue + rvalue;
            case "-":
              return lvalue - rvalue;
            case "*":
              return lvalue * rvalue;
            case "/":
              return lvalue / rvalue;
            default:
              throw new Error("Unknown operator " + operator);
          }
        }
      );
  
      handlebarsContext.registerHelper("switch", function (value, options) {
        this._switch_value_ = value;
        this._switch_break_ = false;
        let html = options.fn(this);
        delete this._switch_value_;
        delete this._switch_break_;
        return html;
      });
  
      handlebarsContext.registerHelper("case", function (value, options) {
        if (value === this._switch_value_) {
          this._switch_break_ = true;
          return options.fn(this);
        }
      });
  
      handlebarsContext.registerHelper("default", function (options) {
        if (!this._switch_break_) {
          return options.fn(this);
        }
      });
    },
  };