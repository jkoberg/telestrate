"use strict";
define([], function() {
// just an array that knows how to keep itself in order by key
// insertion of keys past the ends is optimized.
// binary search into ordered array used otherwise
    
    function OrderedArray(keyfunc) {
        if(keyfunc == undefined) {
            keyfunc = function identity(i){return i};
            }
        this.set_keyfunc(keyfunc);
        this.arr = [];
        }
    OrderedArray.prototype = {
      set_keyfunc: function(keyfunc) {
        this.keyfunc = keyfunc;
        this.sortfunc = function(a, b){
            var ka = keyfunc(a), kb = keyfunc(b);
            if(ka > kb) {
                return 1;
                }
            else {
                if(ka == kb) {
                    return 0;
                    }
                else {
                    return -1;
                    }
                }
            };
        },
      push: function(i) {
        return this.insert(i);
        },
      unshift: function(i) {
        return this.insert(i);
        },
      pop: function() {
        return this.arr.pop();
        },
      shift: function(n) {
        return this.arr.shift(n);
        },
      first: function() {
        return this.arr[0];
        },
      last: function() {
        var arr = this.arr;
        return arr[arr.length - 1];
        },
      firstkey: function() {
        var a;
        return (((a = this.first()) === undefined) ? undefined : this.keyfunc(a)) ;
        },
      lastkey: function() {
        var a;
        return (((a = this.last()) === undefined) ? undefined : this.keyfunc(a));
        },
      slice: function(start, end) {
        return this.arr.slice(start, end);
        },
      forEach: function(f) {
        return this.arr.forEach(f);
        },
      load: function(newarr) {
        this.arr = newarr.slice();
        this.arr.sort(this.sortfunc);
        return this;
        },
      clear: function() {
        this.arr.splice(0, this.arr.length);
        },
      size: function() {
        return this.arr.length;
        },
    
      binarysearch: function(okey, keyfunc) {
        var lower = 0;
        var middle;
        var arr = this.arr;
        var upper = arr.length;
        while ( lower <= upper ) { 
             if ( okey > keyfunc(arr[middle = ((lower + upper) >> 1)]) )
                lower = middle + 1;
             else
                upper = (okey == keyfunc(arr[middle])) ? -2 : middle - 1;
         }
         return (upper == -2) ? {found:true, index:middle, item:arr[middle]} : {found:false, index:upper + 1};
        },
    
      search: function(key) {
        var arr = this.arr;
        var N = arr.length;
        var newidx;
        var kfunc = this.keyfunc;
        var testkey, item;
        // dont know if the binary search insertion was stable before, but its not after this
        if( N < 1 ) {
            newidx = 0;
            }
        else if( key >= (testkey = kfunc(item=arr[N-1])) ) {
            newidx = N;
            }
        else if( key <= (testkey = kfunc(item=arr[0])) ) {
            newidx = 0;
            }
        else {
            return this.binarysearch(key, kfunc);
            }
        if(testkey == key) {
            return {found:true, index: newidx, item:item};
            }
        else {
            return {found:false, index: newidx}
            }
        },
    
      insert: function(newelem) {
        var newkey = this.keyfunc(newelem);
        var result = this.search(newkey);
        this.arr.splice(result.index, 0, newelem);
        return this;
        },
    
      remove: function(oldelem) {
        var self = this;
        var key_obj_func = function(item) {
            return [self.keyfunc(item), item];
            };
        var oldkey = key_obj_func(oldelem);
        var result = this.binarysearch(oldkey, key_obj_func);
        if(result.found) {
            this.arr.splice(result.index, 1);
            return 1;
            }
        return 0;
        },
    
      remove_key: function(oldkey) {
        var self = this;
        result = this.search(oldkey);
        if(result.found) {
            var howmany = 1;
            while( oldkey == this.keyfunc( this.arr[result.index + howmany])) {
                howmany++;
                }
            this.arr.splice(result.index, howmany);
            return howmany;
            }
        },
    
      slice_key: function(startkey, endkey) {
        var startidx = this.search(startkey).index;
        var endidx = this.search(endkey).index;
        return this.arr.slice(startidx, endidx);
        },
    }
    
    return {
        OrderedArray: OrderedArray
    };
});

