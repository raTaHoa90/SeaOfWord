'use strict';

const 
    BCD = 'Content-Disposition: form-data; name="',
    BCT = 'multipart/form-data',
    RN  = "\r\n";

function joinObject(data){
    data = data || {};
    let a = arguments,
        obj, nm, c, 
        i = 1,
        l = a.length;
    for(;i<l;i++)
        if((obj = a[i]) != null)
            for(nm in obj){
                let value = obj[nm];
                if(data === value) continue;
                if(value !== undefined)
                    data[nm] = value
            }
    return data
};

String.randomInt = () => String(Math.random()).slice(2);

class IStorage {
    has(key){ return false; }
    get(key, def){ return undefined; }
    set(key, value){ }
    remove(key) { }
}

class Storage extends IStorage {
    #storeObj;
    #isData = false;

    constructor(type = 'local'){
        super();
        switch(type){
            case 'local':   this.#storeObj = localStorage;   break;
            case 'session': this.#storeObj = sessionStorage; break;

            case 'data':    this.#storeObj = {};             
                            this.#isData = true;
                            break;
        }
    }

    #_s(key){
        if(typeof(key) != 'string')
            key = JSON.stringify(key);
        return key;
    }

    has(key){
        return this.#_s(key) in this.#storeObj;
    }

    get(key, def){
        let value = this.#storeObj[this.#_s(key)] ?? def;
        if(this.#isData){
            if(typeof(value) != 'string')
                return value;
            else if(value == '')
                return ''
            try{
                return JSON.parse(value);
            }catch(e){
                return value;
            }
        } else try{
            return JSON.parse(value);
        }catch(e){
            return value
        }
    }

    set(key, value){
        this.#storeObj[this.#_s(key)] = this.#isData ? value : this.#_s(value);
    }

    remove(key){
        if(this.#isData)
            delete this.#storeObj[this.#_s(key)];
        else
            this.#storeObj.removeItem(this.#_s(key));
    }

}


class CookieStorage extends IStorage {
    #isCookieActive;
    #storage;
    constructor(){
        super();
        if(!document.cookie) 
            document.cookie='test=test;max-age=1';
        if(document.cookie){
            this.#isCookieActive = true;
            this.#storage = new Storage('data');
        } else {
            this.#isCookieActive = false;
            this.#storage = new Storage();
        }

        let kvArray = document.cookie;
        if(kvArray === "")
            return;

        kvArray.split('; ').forEach(kv => {
            let ps = kv.indexOf('=');
            this.#storage.set(kv.substring(0, ps), decodeURIComponent(kv.substring(ps + 1)));
        });
    }

    has(key){
        return this.#storage.has(key);
    }

    get(key, def){
        return this.#storage.get(key) ?? def;
    }

    set(key, value, daysToLive, path, domain, secure){
        let cookie = key + '=' + encodeURIComponent(value);

        if(daysToLive && typeof(daysToLive) == "number")
            cookie += "; max-age=" + (daysToLive * 86400);
        if(path)
            cookie += "; path=" + path;
        if(domain)
            cookie += "; domain=" + domain;
        if(secure)
            cookie += "; secure";

        this.#storage.set(key, value);
        if(this.#isCookieActive)
            document.cookie = cookie;
    }

    remove(key){
        if(this.#isCookieActive){
            let d = new Date();
            d.setTime(d.getTime() - 1000);
            if(d.toUTCString)
                d = d.toUTCString();
            document.cookie = key + '=; expires=' + d;
        }
        this.#storage.remove(key);
    }
}

class JSApp {
    #cookieStorage;
    #initKey;
    #isActive;
    #storage;
    constructor(appName){
        appName = appName.replace(/ /g, '_');
        this.#cookieStorage = new CookieStorage();
        this.#initKey = String.randomInt();
        this.#cookieStorage.set(appName + '_init_key', this.#initKey);
        this.#isActive = true;
        this.#storage = new Storage();
        setInterval(() =>{ 
            this.#cookieStorage = new CookieStorage();
            this.#isActive = this.#cookieStorage.get(appName + '_init_key') == this.#initKey 
        }, 1000);
    }

    get cookie(){ return this.#cookieStorage; }
    get hasActive(){ return this.#isActive; }
    get storage(){ return this.#storage; }

    levelStart(num){
        this.#storage.set('save_level', num);
        this.#storage.set('save_words', '')
    }

    levelAddWord(word){
        let words = this.#storage.get('save_words', '');
        if(words != '')
            words += ',';
        this.#storage.set('save_words', words + word);
    }

    levelWords(){
        let words = this.#storage.get('save_words', '');
        if(words == '')
            return JSON.stringify([]);
        else
            return JSON.stringify(words.split(','));
    }
}


