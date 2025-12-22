{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  sops.secrets = {
    "oidc_clients/immich/id" = {
      owner = "immich";
    };
    "oidc_clients/immich/secret" = {
      owner = "immich";
    };
  };

  sops.templates."immich.json" = {
    owner = "immich";
    content = ''
      {
        "ffmpeg": {
          "crf": 23,
          "threads": 0,
          "preset": "ultrafast",
          "targetVideoCodec": "h264",
          "acceptedVideoCodecs": ["h264"],
          "targetAudioCodec": "aac",
          "acceptedAudioCodecs": ["aac", "mp3", "libopus", "pcm_s16le"],
          "acceptedContainers": ["mov", "ogg", "webm"],
          "targetResolution": "720",
          "maxBitrate": "0",
          "bframes": -1,
          "refs": 0,
          "gopSize": 0,
          "temporalAQ": false,
          "cqMode": "auto",
          "twoPass": false,
          "preferredHwDevice": "auto",
          "transcode": "required",
          "tonemap": "hable",
          "accel": "disabled",
          "accelDecode": false
        },
        "backup": {
          "database": {
            "enabled": true,
            "cronExpression": "0 02 * * *",
            "keepLastAmount": 14
          }
        },
        "job": {
          "backgroundTask": {
            "concurrency": 5
          },
          "smartSearch": {
            "concurrency": 2
          },
          "metadataExtraction": {
            "concurrency": 5
          },
          "faceDetection": {
            "concurrency": 2
          },
          "search": {
            "concurrency": 5
          },
          "sidecar": {
            "concurrency": 5
          },
          "library": {
            "concurrency": 5
          },
          "migration": {
            "concurrency": 5
          },
          "thumbnailGeneration": {
            "concurrency": 3
          },
          "videoConversion": {
            "concurrency": 1
          },
          "notifications": {
            "concurrency": 5
          }
        },
        "logging": {
          "enabled": true,
          "level": "log"
        },
        "machineLearning": {
          "enabled": true,
          "urls": ["http://localhost:3003"],
          "clip": {
            "enabled": true,
            "modelName": "ViT-B-32__openai"
          },
          "duplicateDetection": {
            "enabled": true,
            "maxDistance": 0.01
          },
          "facialRecognition": {
            "enabled": true,
            "modelName": "buffalo_l",
            "minScore": 0.7,
            "maxDistance": 0.5,
            "minFaces": 3
          }
        },
        "map": {
          "enabled": true,
          "lightStyle": "https://tiles.immich.cloud/v1/style/light.json",
          "darkStyle": "https://tiles.immich.cloud/v1/style/dark.json"
        },
        "reverseGeocoding": {
          "enabled": true
        },
        "metadata": {
          "faces": {
            "import": false
          }
        },
        "oauth": {
          "autoLaunch": true,
          "autoRegister": true,
          "buttonText": "Login with OAuth",
          "clientId": "${config.sops.placeholder."oidc_clients/immich/id"}",
          "clientSecret": "${config.sops.placeholder."oidc_clients/immich/secret"}",
          "defaultStorageQuota": 200,
          "enabled": true,
          "issuerUrl": "https://auth.fstn.top",
          "mobileOverrideEnabled": false,
          "mobileRedirectUri": "",
          "scope": "openid email profile",
          "signingAlgorithm": "RS256",
          "profileSigningAlgorithm": "RS256",
        },
        "passwordLogin": {
          "enabled": true
        },
        "storageTemplate": {
          "enabled": false,
          "hashVerificationEnabled": true,
          "template": "{{y}}/{{y}}-{{MM}}-{{dd}}/{{filename}}"
        },
        "image": {
          "thumbnail": {
            "format": "webp",
            "size": 250,
            "quality": 80
          },
          "preview": {
            "format": "jpeg",
            "size": 1440,
            "quality": 80
          },
          "colorspace": "p3",
          "extractEmbedded": false
        },
        "newVersionCheck": {
          "enabled": true
        },
        "trash": {
          "enabled": true,
          "days": 30
        },
        "theme": {
          "customCss": ""
        },
        "library": {
          "scan": {
            "enabled": true,
            "cronExpression": "0 0 * * *"
          },
          "watch": {
            "enabled": false
          }
        },
        "server": {
          "externalDomain": "https://photos.fstn.top",
          "loginPageMessage": ""
        },
        "notifications": {
          "smtp": {
            "enabled": false,
            "from": "",
            "replyTo": "",
            "transport": {
              "ignoreCert": false,
              "host": "",
              "port": 587,
              "username": "",
              "password": ""
            }
          }
        },
        "user": {
          "deleteDelay": 7
        }
      }
    '';
  };

  services.my-immich = {
    enable = true;
    host = "127.0.0.1";
    port = 2816;
    database = {
      createDB = false;
    };
    settingsFile = "${config.sops.templates."immich.json".path}";
  };

  users.users.immich = {
    isSystemUser = true;
  };

  users.users.nginx.extraGroups = [ "acme" ];
  services.nginx = {
    enable = true;
    virtualHosts."photos.fstn.top" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.my-immich.port}";
        proxyWebsockets = true;
        recommendedProxySettings = true;
        extraConfig = ''
          client_max_body_size 50000M;
          proxy_read_timeout   600s;
          proxy_send_timeout   600s;
          send_timeout         600s;
        '';
      };
    };
  };

  services.postgresql = {
    enable = true;
    ensureDatabases = [ "immich" ];
    ensureUsers = [
      {
        name = "immich";
        ensureDBOwnership = true;
      }
    ];
    authentication = pkgs.lib.mkOverride 10 ''
      #type  database  DBuser    auth-method
      local  immich    immich    peer
      local  immich    postgres  peer
    '';
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "pasha@fstn.top";
  };
}
