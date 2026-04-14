{ user, lib, ... }:
{
  qnix = {
    desktop.clientPrNotify.enable = false;

    status = {
      vm = true;
    };
    system = {
      shell = {
        showIcons = true;
      };

      starship = {
        enable = true;
      };

      users = {
        enable = true;
        defaultExtraGroups = [
          "audio"
          "video"
          "users"
        ];

        users.${user} = {
          kind = "normal";
          group = user;
          home = "/home/${user}";
          description = "Quirin Brändli";
          extraGroups = [ "wheel" ];
          initialHashedPassword = "$y$j9T$ZbVZ.p8xaCWvL.ULkJHAH1$4hwPBaX7Thcj41eFvpB2KfWVn0nKpCyalpkIigG6yc1";
          openssh.authorizedKeys.keys = [
            "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDk4DIfOYj5u7Gy01r5eVUuJzaniD8N1pJqOmxtgWRaiMlS+v5Za/Xu2vRpMNoO2lb8nr/FNev4p1wuzNEQjJoEcLTM0JMbUs+4AakUbdOq2P9rAH4A7rNP24fcVtAjSGp/g9krWA3J/WxttNJ0HGfNuSCX871gy6K36KF7l3Jpnfz6h+RwwNsvxTiP/a8S2WFuzr3Wt49px7k4usyQBQoBsOR9EkeqvERsWkBFOltDlqi6GbLTFmaV7B1LQPlAyBOnzvJ0Jp/IM4eyzR6Bc6pVoWxUH619GBifL85qCTGgPDMVnljxRDd0gt8bIueF41lEM/1arJQNH8XdUIF/mX7u7hNYw7MVPmkkwbLy2NUjh0/5RzU8hdE3J9aLRT/EwjZF/0ratIRvjNvGohm0U84jjraCmfZqezgaL3E9DCgXabgDAex9lVlDG/N6b07J0MJ8w2enbOI344iHv2ZpcODoi2ZB674mBDNsarmIUsi2vacCN8/pogirNFDNrU5jEF2lVHrJjNka0sTPlhrk1EoiT1dOcd9X3+STM7SEcY5R8YARCxBD3q3RG1u6f1akFN+QyvEUiV+hVtfrKnTwl2ldZ7Dmlbj7ghhudQQrRNGQ5PvjhNbTLtk+l4sfRbDiiVA0BU9AZiqZq0PeVXErJft2TTPP8UKGN35qGly4YHzfhw== cardno:25_390_975"
          ];
        };
      };
    };

    security = {
      sops.enable = false;
      yubikey = {
        u2f.mappings = {
          "q.braendli" = [
            ":WL1eNX3H4cqCpOdlFLskeKHVkf+SUVng34Ch6rxwn5gw+bJrTyH7wBaYE/iY0Rl4Ab0mNJrTtoUqjLaRNvhWbA==,DX5g1dye2T+mX8tNyMg05W3NrbDE527OCWv6BcUgb63H0zEu4BEl9zWlf3tVOINlqyHcS988QVzfzfHKXT5Abw==,es256,+presence"
          ];
        };
      };
    };

    storage = {
      impermanence.enable = true;
    };
  };
}
