"use strict";
define([], function() {
//
// ---- Binary Heap copied from http://eloquentjavascript.net/appendix2.html ---------------
//
    function BinaryHeap(scoreFunction){
      this.content = [];
      this.scoreFunction = scoreFunction;
    }
    
    BinaryHeap.prototype = {
      push: function(element) {
        this.content.push(element);
        this.bubbleUp(this.content.length - 1);
      },
    
      pop: function() {
        var result = this.content[0];
        var end = this.content.pop();
        if (this.content.length > 0) {
          this.content[0] = end;
          this.sinkDown(0);
        }
        return result;
      },
    
      popUntil: function(score, callback) {
        var results = [];
        while(this.content.length > 0 && this.scoreFunction(this.peek()) <= score) {
            if( callback != undefined ) {
                results.push(callback(this.pop()));
                }
            }
        return results; 
      },
    
      clear: function() {
        this.content = [];
      },
    
      forEach: function(callback) {
        return this.content.forEach(callback);
      },
    
      peek: function() {
        return this.content[0];
      },
    
      remove: function(node) {
        var len = this.content.length;
        for (var i = 0; i < len; i++) {
          if (this.content[i] == node) {
            var end = this.content.pop();
            if (i != len - 1) {
              this.content[i] = end;
              if (this.scoreFunction(end) < this.scoreFunction(node))
                this.bubbleUp(i);
              else
                this.sinkDown(i);
            }
            return;
          }
        }
        throw new Error("Node not found.");
      },
    
      size: function() {
        return this.content.length;
      },
    
      bubbleUp: function(n) {
        var element = this.content[n];
        while (n > 0) {
          var parentN = Math.floor((n + 1) / 2) - 1,
              parent = this.content[parentN];
          if (this.scoreFunction(element) < this.scoreFunction(parent)) {
            this.content[parentN] = element;
            this.content[n] = parent;
            n = parentN;
          }
          else {
            break;
          }
        }
      },
    
      sinkDown: function(n) {
        var length = this.content.length,
            element = this.content[n],
            elemScore = this.scoreFunction(element);
        while(true) {
          var child2N = (n + 1) * 2, child1N = child2N - 1;
          var swap = null;
          if (child1N < length) {
            var child1 = this.content[child1N],
                child1Score = this.scoreFunction(child1);
            if (child1Score < elemScore)
              swap = child1N;
          }
          if (child2N < length) {
            var child2 = this.content[child2N],
                child2Score = this.scoreFunction(child2);
            if (child2Score < (swap == null ? elemScore : child1Score))
              swap = child2N;
          }
          if (swap != null) {
            this.content[n] = this.content[swap];
            this.content[swap] = element;
            n = swap;
          }
          else {
            break;
          }
        }
      }
    };
    
    return {
        BinaryHeap: BinaryHeap,
    };

});
