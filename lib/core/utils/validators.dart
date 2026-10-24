import 'package:flutter/widgets.dart';
import 'package:lengoal/l10n/l10n.dart';

class Validators {
  const new();

  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,10}$',
  );
  static final RegExp _uppercase = RegExp('[A-Z]');
  static final RegExp _lowercase = RegExp('[a-z]');
  static final RegExp _specialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>_\-]');
  static final RegExp _phoneDigits = RegExp(r'^[0-9]{10,15}$');

  static const int _maxLocalPartLength = 64;
  static const int _maxEmailLength = 254;

  static const Set<String> _invalidTlds = {
    'comm',
    'coom',
    'con',
    'cim',
    'vom',
    'xom',
    'coм',
    'orgg',
    'og',
    'orgг',
    'nett',
    'ner',
    'met',
    'gmial',
    'gmal',
    'gmaill',
  };

  static const Set<String> _disposableDomains = {
    'yopmail.com',
    'yopmail.fr',
    'yopmail.net',
    'tempmail.com',
    'temp-mail.org',
    'temp-mail.io',
    'guerrillamail.com',
    'guerrillamail.org',
    'guerrillamail.net',
    'guerrillamail.biz',
    'sharklasers.com',
    'grr.la',
    'guerrillamailblock.com',
    'mailinator.com',
    'mailinator.net',
    'mailinator.org',
    'maildrop.cc',
    'throwaway.email',
    'throwawaymail.com',
    'fakeinbox.com',
    'fakemailgenerator.com',
    'getnada.com',
    'nada.email',
    'tempail.com',
    'tempr.email',
    'tempmailo.com',
    'dispostable.com',
    'mailnesia.com',
    'trashmail.com',
    'trashmail.net',
    'trashmail.org',
    'trashemail.de',
    '10minutemail.com',
    '10minutemail.net',
    '10minmail.com',
    'minutemail.com',
    'emailondeck.com',
    'mohmal.com',
    'mohmal.im',
    'tempinbox.com',
    'burnermail.io',
    'discard.email',
    'disposablemail.com',
    'dropmail.me',
    'emailfake.com',
    'emkei.cz',
    'fakemail.net',
    'getairmail.com',
    'harakirimail.com',
    'hmamail.com',
    'mailcatch.com',
    'mailchop.com',
    'maildx.com',
    'mailexpire.com',
    'mailfree.ga',
    'mailhazard.com',
    'mailhz.me',
    'mailmoat.com',
    'mailnull.com',
    'mailsac.com',
    'mailslite.com',
    'mailtemp.net',
    'meltmail.com',
    'mintemail.com',
    'mytemp.email',
    'mytrashmail.com',
    'nomail.xl.cx',
    'objectmail.com',
    'otherinbox.com',
    'owlpic.com',
    'proxymail.eu',
    'punkass.com',
    'putthisinyourspamdatabase.com',
    'quickinbox.com',
    'receiveee.com',
    'recursor.net',
    'regbypass.com',
    'safetymail.info',
    'sendspamhere.com',
    'shitmail.me',
    'spamavert.com',
    'spambox.us',
    'spamcannon.com',
    'spamcannon.net',
    'spamcero.com',
    'spamcorptastic.com',
    'spamcowboy.com',
    'spamcowboy.net',
    'spamcowboy.org',
    'spamday.com',
    'spamex.com',
    'spamfree24.com',
    'spamfree24.de',
    'spamfree24.eu',
    'spamfree24.info',
    'spamfree24.net',
    'spamfree24.org',
    'spamgoes.in',
    'spamgourmet.com',
    'spamherelots.com',
    'spamhole.com',
    'spamify.com',
    'spaminator.de',
    'spamkill.info',
    'spaml.com',
    'spaml.de',
    'spamlot.net',
    'spammotel.com',
    'spamobox.com',
    'spamoff.de',
    'spamslicer.com',
    'spamspot.com',
    'spamstack.net',
    'spamthis.co.uk',
    'spamthisplease.com',
    'spamtrail.com',
    'spamtroll.net',
    'superrito.com',
    'teleworm.us',
    'tempemail.co.za',
    'tempemail.com',
    'tempemail.net',
    'tempomail.fr',
    'temporaryemail.net',
    'temporaryemail.us',
    'temporaryforwarding.com',
    'temporaryinbox.com',
    'thanksnospam.info',
    'thankyou2010.com',
    'thisisnotmyrealemail.com',
    'throwam.com',
    'tilien.com',
    'tmailinator.com',
    'trash2009.com',
    'trash2010.com',
    'trash2011.com',
    'trashbox.eu',
    'trashdevil.com',
    'trashdevil.de',
    'trashmail.at',
    'trashmail.me',
    'trashmail.ws',
    'trashmailer.com',
    'trashymail.com',
    'trashymail.net',
    'trbvm.com',
    'twinmail.de',
    'tyldd.com',
    'uggsrock.com',
    'upliftnow.com',
    'uplipht.com',
    'venompen.com',
    'veryrealemail.com',
    'viditag.com',
    'viewcastmedia.com',
    'viewcastmedia.net',
    'viewcastmedia.org',
    'webm4il.info',
    'wegwerfadresse.de',
    'wegwerfemail.com',
    'wegwerfemail.de',
    'wegwerfmail.de',
    'wegwerfmail.info',
    'wegwerfmail.net',
    'wegwerfmail.org',
    'wetrainbayarea.com',
    'wetrainbayarea.org',
    'wh4f.org',
    'whopy.com',
    'willselfdestruct.com',
    'winemaven.info',
    'wronghead.com',
    'wuzup.net',
    'wuzupmail.net',
    'wwwnew.eu',
    'xagloo.com',
    'xemaps.com',
    'xents.com',
    'xmaily.com',
    'xoxy.net',
    'yep.it',
    'yogamaven.com',
    'yuurok.com',
    'zehnminutenmail.de',
    'zippymail.info',
    'zoaxe.com',
    'zoemail.org',
  };

  static const Map<String, String> _domainTypos = {
    'gmial.com': 'gmail.com',
    'gmal.com': 'gmail.com',
    'gamil.com': 'gmail.com',
    'gnail.com': 'gmail.com',
    'gmail.con': 'gmail.com',
    'gmail.comm': 'gmail.com',
    'gmail.om': 'gmail.com',
    'gmail.co': 'gmail.com',
    'gmaill.com': 'gmail.com',
    'gmailc.om': 'gmail.com',
    'yahooo.com': 'yahoo.com',
    'yaho.com': 'yahoo.com',
    'yahoo.con': 'yahoo.com',
    'yahoo.comm': 'yahoo.com',
    'hotmal.com': 'hotmail.com',
    'hotmial.com': 'hotmail.com',
    'hotmail.con': 'hotmail.com',
    'hotmail.comm': 'hotmail.com',
    'outlok.com': 'outlook.com',
    'outloo.com': 'outlook.com',
    'outlook.con': 'outlook.com',
    'outlook.comm': 'outlook.com',
    'iclod.com': 'icloud.com',
    'icloud.con': 'icloud.com',
    'icloud.comm': 'icloud.com',
  };

  static String? email(BuildContext context, String? value) {
    if (value == null || value.trim().isEmpty) {
      return context.l10n.validationRequired(context.l10n.loginEmailLabel);
    }

    final email = value.trim().toLowerCase();

    if (email.length > _maxEmailLength) {
      return context.l10n.validationEmailTooLong;
    }

    if (!_emailRegex.hasMatch(email)) {
      return context.l10n.validationEmailInvalid;
    }

    final parts = email.split('@');
    if (parts.length != 2) {
      return context.l10n.validationEmailInvalid;
    }

    final localPart = parts[0];
    final domain = parts[1];

    if (localPart.length > _maxLocalPartLength) {
      return context.l10n.validationEmailInvalid;
    }
    if (localPart.startsWith('.') ||
        localPart.endsWith('.') ||
        localPart.contains('..') ||
        domain.startsWith('.') ||
        domain.endsWith('.') ||
        domain.contains('..')) {
      return context.l10n.validationEmailInvalid;
    }

    final domainParts = domain.split('.');
    final tld = domainParts.last;

    if (_invalidTlds.contains(tld)) {
      return context.l10n.validationEmailTypoTld;
    }

    if (_disposableDomains.contains(domain)) {
      return context.l10n.validationEmailDisposable;
    }
    if (_disposableDomains.any((d) => domain.endsWith('.$d'))) {
      return context.l10n.validationEmailDisposable;
    }

    final suggestion = _domainTypos[domain];
    if (suggestion != null) {
      return context.l10n.validationEmailDidYouMean('$localPart@$suggestion');
    }

    return null;
  }

  static String? password(
    BuildContext context,
    String? value, {
    int minLength = 8,
  }) {
    if (value == null || value.isEmpty) {
      return context.l10n.validationRequired(context.l10n.loginPasswordLabel);
    }
    if (value.length < minLength) {
      return context.l10n.validationPasswordTooShort(minLength);
    }
    return null;
  }

  static String? strongPassword(
    BuildContext context,
    String? value, {
    int minLength = 8,
  }) {
    final basic = password(context, value, minLength: minLength);
    if (basic != null) return basic;
    final v = value!;
    if (!_uppercase.hasMatch(v) ||
        !_lowercase.hasMatch(v) ||
        !_specialChar.hasMatch(v)) {
      return context.l10n.validationPasswordWeak;
    }
    return null;
  }

  // Count of strongPassword's criteria met (0-4). Backs the
  // strength bar's fill amount.
  static int passwordStrength(String value) {
    var score = 0;
    if (value.length >= 8) score++;
    if (_uppercase.hasMatch(value)) score++;
    if (_lowercase.hasMatch(value)) score++;
    if (_specialChar.hasMatch(value)) score++;
    return score;
  }

  static String? notEmpty(BuildContext context, String? value, String field) {
    if (value == null || value.trim().isEmpty) {
      return context.l10n.validationRequired(field);
    }
    return null;
  }

  static String? phoneNumber(BuildContext context, String? value) {
    if (value == null || value.trim().isEmpty) {
      return context.l10n.validationRequired(context.l10n.registerPhoneLabel);
    }
    if (!_phoneDigits.hasMatch(value.trim())) {
      return context.l10n.validationPhoneInvalid;
    }
    return null;
  }

  static String? confirmPassword(
    BuildContext context,
    String? value,
    String original, {
    String? fieldLabel,
  }) {
    if (value == null || value.isEmpty) {
      return context.l10n.validationRequired(
        fieldLabel ?? context.l10n.loginPasswordLabel,
      );
    }
    if (value != original) {
      return context.l10n.validationPasswordMismatch;
    }
    return null;
  }
}
