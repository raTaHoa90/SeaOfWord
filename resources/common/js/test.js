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

class Ajax {
    #testXhr = true;
    #options = {
        async: true,
        dataType: 'text',
        types: {
            text:   r => r.responseText,
            json:   r => JSON.parse(r.responseText),
            script: r => eval(r.responseText),
            xml:    r => r.responseXML,
            binary: r => r.response
        },
        contentType: "application/x-www-form-urlencoded; charset=UTF-8", // тип контента по умолчанию, (multipart/form-data, для отправок с файлами) 
        url: location.href,
        type: 'GET',
        send: 'send',
        binary: false
        /*
			form: <FORM>                     // указание формы, с которой автоматически добавлять данные (только для POST)
			data: <FORM|Object|String|Array> // данные, которые следует отправить в запросе
			method: <=type>                  // тип отправки GET, POST, PUT, DELETE, TRACE
			multi: <boolean>                 // если надо передавать в стиле multipart/form-data
			headers: <hash>                  // передаваемые заголовки в ajax
			login:
			password:
			url:
			timeout: <milisec>               // время ожидания
			boundary: <num>                  // принудительный BIN
			send: <string>                   // метод отправки данных
			binary: <bool>                   // если ненужно кодировать данные для отправки (только для POST)

			load:     <func> // событие, при успешном получении данных 
			error:    <func> // событие при неуспешном получении данных
			abort:    <func> // событие при отмене запроса
			time:     <func> // событие по привышении ожидания
			progress: <func> // событие прогресса загрузки с сервера
			upload:   <func> // прогресс загрузки даннын на сервер
        */
    }

    constructor(options){
        if(options)
            joinObject(this.#options, options)
    }

    #_xhr(){
        if(!this.#testXhr) 
            return false;
        try{
            return new Window.XMLHttpRequest();
        }catch(e){
            this.#testXhr = false;
            return false;
        }
    }

    #_to_param(name, value, boundary){
        if(value == undefined) 
            return [];

        if(Array.isArray(value))
            return value.reduce(function(result, data){
                result.push(boundary 
                    ? BCD + name + '"' + RN + RN + data + RN 
                    : name + '=' + encodeURIComponent(data) );
                return result;
            }, []);
        return [boundary 
            ? BCD + name + '"' + RN + RN + value + RN 
            : name + '=' + encodeURIComponent(value)
        ]
    }
    #_to_result(arr, boundary){
        return arr.join(boundary ? '--' + boundary + RN : '&' ) + (boundary ? '--' + boundary + '--' + RN : '');
    }
    #_getObj(obj, boundary){
        if(!(Array.isArray(obj) || typeof(obj) == 'object')) 
            return boundary ? this.#_to_result(obj, boundary) : 'value=' + encodeURIComponent(obj);
        let result = boundary ? [RN] : [];
        for(let i in obj)
            if(![undefined, null].includes(obj[i]))
                [].push.apply(result, this.#_to_param(i, obj[i], boundary));
    }

    send(url, options) {
        if(typeof url == 'object'){
            options = url;
            url = undefined;
        }

        var opts = joinObject({}, this.#options, options);
        let method = ((opts.method ? opts.method : opts.type) || 'POST').toUpperCase(),
            multi;
        url = url || opts.url;
        data = opts.data;
        boundary = opts.boundary || String.randomInt();

        if(opts.binary && method != 'GET')
            multi = 0;
        else {
            multi = opts.multi || false;
            if(data)
                data = this.#_getObj(data, multi ? boundary : null);
        }

        let URL = url + ( method == 'GET' && data ? '?' + data : '');
        let xhr = this.#_xhr(),
            contentType;
        if(multi)
            contentType = BCT + '; boundary=' + boundary;
        else
            contentType = opts.contentType;

        xhr.open(method, URL, opts.async, opts.login, opts.password);

        xhr.setRequestHeader("X-Requested-With", "XMLHttpRequest");
        if(contentType != BCT)
            xhr.setRequestHeader('Content-Type', contentType);

        if(opts.headers)
            for(let i in opts.headers)
                x.setRequestHeader(i, opts.headers[i]);
        
        if(opts.timeout)
            xhr.timeout = opts.timeout;

        if(opts.upload){
            var ttl = 0;
            xhr.upload.onprogress = e => { ttl = e.total; opts.upload(e.loaded, ttl, e.lengthComputable) };
            xhr.upload.onload = e => opts.upload(ttl, ttl);
        }

        if(opts.progress)
            xhr.onprogress = e => opts.progress(e.loaded, e.total, e.lengthComputable);

        xhr.onreadystatechange = function(){
            if(xhr.readyState==4){
                let statusCode = xhr.status, 
                    statusText = xhr.statusText, 
                    headers = xhr.getAllResponseHeaders();
                
                if(statusCode > 199 && statusCode < 300){
                    if(opts.load)
                        opts.load(this.#options.types[opts.dataType](xhr), statusCode, headers);
                } else {
                    if(opts.error)
                        opts.error(xhr, statusCode, headers);
                }
            }
        };
        xhr.onabort = opts.abort;
        xhr.ontimeout = opts.time;

        xhr[opts.send](method=='POST' ? data || null : null);
        return boundary;
    }

    #_ajax( method, url, data, callback, type ) { 
        // Shift arguments if data argument was omitted
        if ( typeof(data) == 'function' ) {
            type = type || ccallback;
            callback = data;
            data = undefined;
        }

        // The url can be an options object (which then must have .url)
        return this.send( {
            url,
            type: method,
            dataType: type || this.#options.dataType,
            data,
            load: callback   // функция обработчик
        } );
    }

    static get(url, data, callback, type){
        return (new Ajax()).#_ajax('GET', url, data, callback, type);
    }

    static post(url, data, callback, type){
        return (new Ajax()).#_ajax('POST', url, data, callback, type);
    }

    static json(url, data, callback){
        return (new Ajax()).#_ajax('POST', url, data, callback, 'json');
    }

    static script(url, data, callback){
        return (new Ajax()).#_ajax('GET', url, data, callback, 'script');
    }
}

class IStorage {
    has(key){ return false; }
    get(key){ return undefined; }
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

    get(key){
        let value = this.#storeObj[this.#_s(key)];
        if(this.#isData){
            if(typeof(value) != 'string')
                return value;
            try{
                return JSON.parse(value);
            }catch(e){
                return value;
            }
        } else 
            return JSON.parse(value);
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

    get(key){
        return this.#storage.get(key);
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
    constructor(appName){
        appName = appName.replace(/ /g, '_');
        this.#cookieStorage = new CookieStorage();
        this.#initKey = String.randomInt();
        this.#cookieStorage.set(appName + '_init_key', this.#initKey);
        this.#isActive = true;
        setInterval(() =>{ 
            this.#cookieStorage = new CookieStorage();
            this.#isActive = this.#cookieStorage.get(appName + '_init_key') == this.#initKey 
        }, 1000);
    }

    get cookie(){ return this.#cookieStorage; }
    get hasActive(){ return this.#isActive; }
}


